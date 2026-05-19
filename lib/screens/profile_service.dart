import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static String? get userId => _auth.currentUser?.uid;

  // 1. Получение данных профиля (Стрим)
  static Stream<DocumentSnapshot> getProfile() {
    if (userId == null) {
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // 2. Обновление профиля
  static Future<void> updateProfile({
    required String name,
    required String login,
    File? avatar,
    File? resume,
  }) async {
    if (userId == null) return;

    Map<String, dynamic> dataToUpdate = {
      'name': name,
      'login': login,
      'email': _auth.currentUser?.email,
    };

    // 🚀 ПРЕВРАЩАЕМ КАРТИНКУ В СТРОКУ BASE64
    if (avatar != null) {
      final bytes = await avatar.readAsBytes();
      final base64String = base64Encode(bytes);
      dataToUpdate['avatarUrl'] = base64String; // Теперь здесь хранится сама картинка!
    }

    // 🚀 ТАКЖЕ ПРЕВРАЩАЕМ ТЕКСТОВЫЙ ФАЙЛ В СТРОКУ
    if (resume != null) {
      final resumeBytes = await resume.readAsBytes();
      final resumeBase64 = base64Encode(resumeBytes);
      
      dataToUpdate['resumeUrl'] = resumeBase64;
      dataToUpdate['resumeName'] = resume.path.split('/').last;
    }

    // Сохраняем все в Firestore (в текстовом виде)
    await _firestore.collection('users').doc(userId).set(
      dataToUpdate,
      SetOptions(merge: true),
    );
  }

  // 3. Проверка текущего пароля
  static Future<bool> verifyPassword(String oldPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false; 
    }
  }

  // 4. Смена пароля
  static Future<void> changePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }
}
