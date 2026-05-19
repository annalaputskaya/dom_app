import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Мой рейтинг"),
      ),
      body: userId == null
          ? const Center(child: Text("Вы не авторизованы"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('reviews') 
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("Пока нет отзывов"));
                }

                final reviews = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final data = reviews[index].data()
                        as Map<String, dynamic>;

                    return _buildReviewCard(data);
                  },
                );
              },
            ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] ?? 0;
    final text = review['text'] ?? '';
    final author = review['reviewerName'] ?? 'Пользователь';

    String date = "";
    if (review['createdAt'] != null) {
      date = DateFormat('dd.MM.yyyy')
          .format((review['createdAt'] as Timestamp).toDate());
    }

    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 имя + дата
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 6),

         
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 💬 текст
          Text(text),
        ],
      ),
    );
  }
}