import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'employer_profile_page.dart';
import 'worker_detail_page.dart';
import 'chat_service.dart';
import 'job_details_page.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .snapshots(),
      builder: (context, chatSnapshot) {
        // Загрузка
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Чат не найден
        if (!chatSnapshot.hasData || !chatSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Чат не найден")),
          );
        }

        // Данные чата
        final chatData = chatSnapshot.data!.data() as Map<String, dynamic>;
        
        // Определяем роль текущего пользователя
        final bool isEmployer = chatData['employerId'] == currentUser?.uid;
        
        // Данные участников
        final Map<String, dynamic>? workerData = chatData['workerData'] != null
            ? Map<String, dynamic>.from(chatData['workerData'])
            : null;
            
        final Map<String, dynamic>? employerData = chatData['employerData'] != null
            ? Map<String, dynamic>.from(chatData['employerData'])
            : null;
        
        // Имена из поля name
        final String workerName = workerData?['name'] ?? chatData['workerName'] ?? 'Строитель';
        final String employerName = employerData?['name'] ?? chatData['employerName'] ?? 'Работодатель';
            
        final String? workerAvatar = workerData?['avatarUrl'];
        final String? employerAvatar = employerData?['avatarUrl'];
        
        // Имя и аватар собеседника
        final String otherUserName = isEmployer ? workerName : employerName;
        final String? otherUserAvatar = isEmployer ? workerAvatar : employerAvatar;
        
        // ID собеседника
        final String otherUserId = isEmployer 
            ? chatData['workerId'] 
            : chatData['employerId'];

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FA),
          
          // AppBar
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                // Загружаем полные данные пользователя из Firestore
                if (otherUserId.isNotEmpty) {
                  try {
                    // Показываем индикатор загрузки
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get();
                    
                    if (!context.mounted) return;
                    Navigator.pop(context); // Закрываем индикатор
                    
                    if (userDoc.exists) {
                      final userData = userDoc.data() as Map<String, dynamic>;
                      
                      if (isEmployer) {
                        // Работодатель смотрит профиль строителя
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkerDetailPage(
                              workerData: userData,
                            ),
                          ),
                        );
                      } else {
                        // Строитель смотрит профиль работодателя
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EmployerProfilePage(
                              userId: otherUserId,
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Пользователь не найден")),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Закрываем индикатор
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Ошибка загрузки профиля: $e")),
                      );
                    }
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 16),
                child: Row(
                  children: [
                    // Аватар собеседника
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: const Color(0xFFF08A08),
                      backgroundImage: otherUserAvatar != null && otherUserAvatar.isNotEmpty
                          ? MemoryImage(base64Decode(otherUserAvatar))
                          : null,
                      child: otherUserAvatar == null || otherUserAvatar.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Имя и подсказка
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherUserName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Нажмите для просмотра профиля",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Body
          body: Column(
            children: [
              // Карточка объявления
              _buildJobCard(chatData),
              
              // Сообщения
              Expanded(
                child: _buildMessagesList(),
              ),
              
              // Поле ввода
              _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // КАРТОЧКА ОБЪЯВЛЕНИЯ
  // =========================================================
  
  Widget _buildJobCard(Map<String, dynamic> chatData) {
    // Форматируем цену для отображения
    final String jobPrice = chatData['jobPrice'] ?? '';
    final bool isNegotiable = jobPrice.toLowerCase() == 'договорная' || jobPrice.isEmpty;
    final String displayPrice = isNegotiable ? "Договорная" : "$jobPrice ₽";
    
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final String jobId = chatData['jobId'] ?? '';
        if (jobId.isEmpty) return;

        try {
          final jobDoc = await FirebaseFirestore.instance
              .collection('jobs')
              .doc(jobId)
              .get();

          if (!jobDoc.exists) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Объявление не найдено")),
              );
            }
            return;
          }

          final jobData = jobDoc.data() as Map<String, dynamic>;
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JobDetailsPage(job: jobData),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Ошибка: $e")),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF08A08).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF08A08).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Иконка
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF08A08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.work, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            // Информация об объявлении
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatData['jobTitle'] ?? 'Без названия',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayPrice,
                    style: const TextStyle(
                      color: Color(0xFFF08A08),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatData['jobLocation'] ?? 'Минск',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFF08A08)),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // СПИСОК СООБЩЕНИЙ
  // =========================================================
  
  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return const Center(
            child: Text("Сообщений пока нет", style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            final bool isMe = message['senderId'] == currentUser?.uid;

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFF08A08) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message['text'] ?? '',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================
  // ПОЛЕ ВВОДА СООБЩЕНИЯ
  // =========================================================
  
  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Текстовое поле
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Введите сообщение",
                  filled: true,
                  fillColor: const Color(0xFFF4F7FA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Кнопка отправки
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF08A08),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  
                  await ChatService.sendMessage(
                    chatId: widget.chatId,
                    text: text,
                  );
                  
                  _controller.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}