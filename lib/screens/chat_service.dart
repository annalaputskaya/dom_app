import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // =========================================================
  // CREATE OR GET CHAT
  // =========================================================

  static Future<String> createOrGetChat({
    required String otherUserId,
    required String jobId,
    required String jobTitle,
    required String jobPrice,
    required String jobPriceType,
    required String jobLocation,
    required Map<String, dynamic> employerData,
    required Map<String, dynamic> workerData,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("Пользователь не авторизован");
    }

    final currentUserId = currentUser.uid;

    // Определяем кто есть кто
    final bool isEmployer = employerData['userId'] == currentUserId;
    final String employerId = isEmployer ? currentUserId : otherUserId;
    final String workerId = isEmployer ? otherUserId : currentUserId;

    // Стабильный ID чата
    final participants = [employerId, workerId];
    participants.sort();
    final chatId = "${participants[0]}_${participants[1]}_$jobId";

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Проверяем существует ли чат
    final existingChat = await chatRef.get();

    if (existingChat.exists) {
      return chatId;
    }

    // Создаем новый чат
    await chatRef.set({
      'chatId': chatId,
      'employerId': employerId,
      'workerId': workerId,
      'participants': [employerId, workerId],
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobPrice': jobPrice,
      'jobPriceType': jobPriceType,
      'jobLocation': jobLocation,
      'employerData': {
        'userId': employerData['userId'],
        'name': employerData['name'] ?? 'Работодатель',
        'avatarUrl': employerData['avatarUrl'] ?? '',
        'email': employerData['email'] ?? '',
        'phone': employerData['phone'] ?? '',
      },
      'workerData': {
        'userId': workerData['userId'],
        'name': workerData['name'] ?? 'Строитель',
        'profession': workerData['profession'] ?? '',
        'experience': workerData['experience'] ?? '',
        'avatarUrl': workerData['avatarUrl'] ?? '',
        'phone': workerData['phone'] ?? '',
        'skills': workerData['skills'] ?? '',
        'education': workerData['education'] ?? '',
        'region': workerData['region'] ?? '',
      },
      'employerName': employerData['name'] ?? 'Работодатель',
      'workerName': workerData['name'] ?? 'Строитель',
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return chatId;
  }

  // =========================================================
  // SEND MESSAGE
  // =========================================================

  static Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Отправляем сообщение
    await chatRef.collection('messages').add({
      'text': text,
      'senderId': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Обновляем последнее сообщение в чате
    await chatRef.update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // DELETE CHAT
  // =========================================================

  static Future<void> deleteChat(String chatId) async {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    
    // Удаляем все сообщения
    final messages = await chatRef.collection('messages').get();
    for (var message in messages.docs) {
      await message.reference.delete();
    }
    
    // Удаляем чат
    await chatRef.delete();
  }

  // =========================================================
  // GET OTHER USER DATA
  // =========================================================

  static Map<String, dynamic>? getOtherUserData(
    Map<String, dynamic> chatData,
    String currentUserId,
  ) {
    final bool isEmployer = chatData['employerId'] == currentUserId;
    
    if (isEmployer) {
      return chatData['workerData'] != null
          ? Map<String, dynamic>.from(chatData['workerData'])
          : null;
    } else {
      return chatData['employerData'] != null
          ? Map<String, dynamic>.from(chatData['employerData'])
          : null;
    }
  }

  // =========================================================
  // GET OTHER USER NAME
  // =========================================================

  static String getOtherUserName(
    Map<String, dynamic> chatData,
    String currentUserId,
  ) {
    final otherUserData = getOtherUserData(chatData, currentUserId);
    
    if (otherUserData != null) {
      return otherUserData['name'] ?? 
          (chatData['employerId'] == currentUserId ? 'Строитель' : 'Работодатель');
    }
    
    return chatData['employerId'] == currentUserId ? 'Строитель' : 'Работодатель';
  }

  // =========================================================
  // GET OTHER USER AVATAR
  // =========================================================

  static String? getOtherUserAvatar(
    Map<String, dynamic> chatData,
    String currentUserId,
  ) {
    final otherUserData = getOtherUserData(chatData, currentUserId);
    return otherUserData?['avatarUrl'];
  }
}
