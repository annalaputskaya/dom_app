import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_page.dart';
import 'chat_service.dart';

class JobDetailsPage extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailsPage({
    super.key,
    required this.job,
  });

  static const Color primaryDark = Color(0xFF0F172A);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color inputBg = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    final String title = job['title'] ?? 'Без названия';
    final String description = job['description'] ?? 'Описание отсутствует';
    final String comment = job['comment'] ?? '';
    final bool isNegotiable = job['isNegotiable'] ?? false;
    final String price = job['price'] ?? '';
    final String priceType = job['priceType'] ?? '';
    final String location = job['location'] ?? 'Не указана';
    final String name = job['name'] ?? 'Автор';
    final String contactMethod = job['contactMethod'] ?? 'Не указан';
    final List<dynamic> phones = job['phones'] ?? [];

    // Форматирование даты
    String formattedDate = '';
    if (job['createdAt'] != null) {
      final Timestamp timestamp = job['createdAt'];
      final DateTime dateTime = timestamp.toDate();
      formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'ru').format(dateTime);
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Детали объявления",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(title, isNegotiable, price, priceType, formattedDate),
            const SizedBox(height: 20),
            
            _buildSectionHeader(textSecondary, "Описание"),
            _buildDescriptionCard(description, comment),
            const SizedBox(height: 20),
            
            _buildSectionHeader(textSecondary, "Контакты и локация"),
            _buildContactsCard(name, location, contactMethod, phones),
            const SizedBox(height: 30),
            
            _buildRespondButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String title, bool isNegotiable, String price, String priceType, String formattedDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: accentOrange, size: 24),
              const SizedBox(width: 8),
              Text(
                isNegotiable ? "Договорная цена" : "$price ₽ $priceType",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isNegotiable ? textSecondary : accentOrange,
                ),
              ),
            ],
          ),
          if (formattedDate.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: inputBg),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Опубликовано: $formattedDate",
                  style: const TextStyle(color: textSecondary, fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description, String comment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Что нужно сделать:",
            style: TextStyle(
              color: textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: primaryDark,
              height: 1.5,
            ),
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: inputBg),
            const SizedBox(height: 12),
            const Text(
              "Дополнительный комментарий:",
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              comment,
              style: const TextStyle(
                fontSize: 15,
                color: primaryDark,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactsCard(String name, String location, String contactMethod, List<dynamic> phones) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconRow(Icons.person_outline, "Заказчик", name),
          const SizedBox(height: 16),
          _buildIconRow(Icons.location_on_outlined, "Локация", location),
          const SizedBox(height: 16),
          _buildIconRow(Icons.contact_mail_outlined, "Способ связи", contactMethod),
          if (contactMethod == "Звонки и сообщения" && phones.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: inputBg),
            const SizedBox(height: 16),
            const Text(
              "Номера телефонов:",
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...phones.map((phone) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    phone.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryDark,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildRespondButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          final currentUser = FirebaseAuth.instance.currentUser;

          if (currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Необходимо войти в аккаунт")),
            );
            return;
          }

          final String? ownerId = job['userId'];
          if (ownerId == null || ownerId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Автор объявления не найден")),
            );
            return;
          }

          if (ownerId == currentUser.uid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Это ваше объявление")),
            );
            return;
          }

          // Получаем данные работодателя
          final employerDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(ownerId)
              .get();
          
          // Убираем ненужный каст
          final employerData = employerDoc.data();
          
          // Получаем данные текущего пользователя (строителя)
          final workerDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
          
          // Убираем ненужный каст
          final workerData = workerDoc.data();

          // Формируем имя строителя
          final String workerFirstName = workerData?['firstName'] ?? '';
          final String workerLastName = workerData?['lastName'] ?? '';
          final String workerFullName = [workerFirstName, workerLastName]
              .where((e) => e.isNotEmpty)
              .join(' ');
          
          final String workerName = workerFullName.isNotEmpty 
              ? workerFullName 
              : workerData?['name'] ?? 
                workerFirstName.isNotEmpty ? workerFirstName : 'Строитель';
          
          // Формируем имя работодателя
          final String employerFirstName = employerData?['firstName'] ?? '';
          final String employerLastName = employerData?['lastName'] ?? '';
          final String employerFullName = [employerFirstName, employerLastName]
              .where((e) => e.isNotEmpty)
              .join(' ');
          
          final String employerName = employerFullName.isNotEmpty 
              ? employerFullName 
              : employerData?['name'] ?? 
                employerFirstName.isNotEmpty ? employerFirstName : 
                job['name'] ?? 'Работодатель';

          // Ищем существующий чат
          final existingChats = await FirebaseFirestore.instance
              .collection('chats')
              .where('jobId', isEqualTo: job['jobId'])
              .where('participants', arrayContains: currentUser.uid)
              .get();

          String chatId = '';

          if (existingChats.docs.isNotEmpty) {
            final existingChat = existingChats.docs.first;
            final data = existingChat.data();
            final participants = List<String>.from(data['participants'] ?? []);
            
            if (participants.contains(ownerId)) {
              chatId = existingChat.id;
            }
          }

          if (chatId.isEmpty) {
            chatId = await ChatService.createOrGetChat(
              otherUserId: ownerId,
              jobId: job['jobId'] ?? '',
              jobTitle: job['title'] ?? '',
              jobPrice: job['price']?.toString() ?? '',
              jobPriceType: job['priceType'] ?? '',
              jobLocation: job['location'] ?? '',
              employerData: {
                'userId': ownerId,
                'name': employerName,
                'firstName': employerData?['firstName'] ?? '',
                'lastName': employerData?['lastName'] ?? '',
                'avatarUrl': employerData?['avatarUrl'] ?? '',
                'email': employerData?['email'] ?? '',
                'phone': employerData?['phone'] ?? '',
              },
              workerData: {
                'userId': currentUser.uid,
                'name': workerName,
                'firstName': workerData?['firstName'] ?? '',
                'lastName': workerData?['lastName'] ?? '',
                'profession': workerData?['profession'] ?? '',
                'experience': workerData?['experience'] ?? '',
                'avatarUrl': workerData?['avatarUrl'] ?? '',
                'phone': workerData?['phone'] ?? '',
                'skills': workerData?['skills'] ?? '',
                'education': workerData?['education'] ?? '',
                'region': workerData?['region'] ?? '',
              },
            );
          }

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(chatId: chatId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Откликнуться",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(Color color, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: textSecondary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}