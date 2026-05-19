import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerProfilePage extends StatelessWidget {

  final String userId;

  static const Color primaryDark =
      Color(0xFF1A2238);

  const EmployerProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Профиль работодателя",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Профиль не найден"),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final name = data['firstName'] ?? 'Не указано';
          final surname = data['lastName'] ?? '';
          final email = data['email'] ?? 'Не указано';
          final company = data['organization'] ?? 'Не указана';
          final avatar = data['avatarUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryDark,
                  backgroundImage:
                      avatar != null && avatar.isNotEmpty
                          ? NetworkImage(avatar)
                          : null,
                  child: avatar == null || avatar.isEmpty
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        )
                      : null,
                ),

                const SizedBox(height: 20),

                Text(
                  "$name $surname",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                _buildInfoTile(
                  Icons.email_outlined,
                  "Почта",
                  email,
                ),

                const SizedBox(height: 12),

                _buildInfoTile(
                  Icons.business_outlined,
                  "Компания",
                  company,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Icon(icon, color: primaryDark),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}