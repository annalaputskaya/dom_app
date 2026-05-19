import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_page.dart';
import 'chat_service.dart';

class WorkerDetailPage extends StatefulWidget {
  final Map<String, dynamic> workerData;

  const WorkerDetailPage({super.key, required this.workerData});

  @override
  State<WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<WorkerDetailPage> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);
  final Color bg = const Color(0xFFF4F7FA);

  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<String> _getUserName(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return "Аноним";
    return data['name'] ?? "Аноним";
  }

  Future<void> _sendReview(String workerUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = await _getUserName(user.uid);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(workerUid)
        .collection('reviews')
        .add({
      "text": _reviewController.text.trim(),
      "rating": _rating,
      "reviewerName": name,
      "createdAt": FieldValue.serverTimestamp(),
    });

    _reviewController.clear();
    setState(() => _rating = 5);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Отзыв успешно добавлен"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _openReviewSheet(String workerUid) {
    _reviewController.clear();
    setState(() => _rating = 5);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Оставить отзыв",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () => setModal(() => _rating = i + 1),
                        icon: Icon(
                          i < _rating ? Icons.star : Icons.star_border,
                          color: accentOrange,
                          size: 30,
                        ),
                      );
                    }),
                  ),

                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Ваш отзыв...",
                      filled: true,
                      fillColor: bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () async {
                        await _sendReview(workerUid);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text("Отправить"),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Функция для открытия чата с проверкой существующего чата
  Future<void> _openChat() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Необходимо войти в аккаунт")),
      );
      return;
    }

    final workerId = widget.workerData['userId'] ?? widget.workerData['uid'];
    if (workerId == null || workerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка: пользователь не найден")),
      );
      return;
    }

    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Проверяем, существует ли уже чат между этими пользователями
      final existingChats = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser.uid)
          .get();

      String existingChatId = '';
      
      // Ищем чат, где есть оба участника
      for (var chatDoc in existingChats.docs) {
        final chatData = chatDoc.data();
        final participants = List<String>.from(chatData['participants'] ?? []);
        if (participants.contains(workerId)) {
          existingChatId = chatDoc.id;
          break;
        }
      }

      if (context.mounted) Navigator.pop(context); // Закрываем индикатор

      // Если чат уже существует - переходим в него
      if (existingChatId.isNotEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Чат уже существует, переходим в него..."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(chatId: existingChatId),
            ),
          );
        }
        return;
      }

      // Если чата нет - создаем новый
      // Получаем данные работодателя (текущего пользователя)
      final employerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final employerData = employerDoc.data();
      
      // Получаем данные строителя
      final workerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(workerId)
          .get();
      
      final workerData = workerDoc.data();

      // Создаем чат с временными данными (без объявления)
      final chatId = await ChatService.createOrGetChat(
        otherUserId: workerId,
        jobId: 'direct_chat_${DateTime.now().millisecondsSinceEpoch}',
        jobTitle: 'Личный чат',
        jobPrice: '',
        jobPriceType: '',
        jobLocation: '',
        employerData: {
          'userId': currentUser.uid,
          'name': employerData?['name'] ?? 'Работодатель',
          'avatarUrl': employerData?['avatarUrl'] ?? '',
          'email': employerData?['email'] ?? '',
          'phone': employerData?['phone'] ?? '',
        },
        workerData: {
          'userId': workerId,
          'name': workerData?['name'] ?? 'Строитель',
          'profession': workerData?['profession'] ?? '',
          'experience': workerData?['experience'] ?? '',
          'avatarUrl': workerData?['avatarUrl'] ?? '',
          'phone': workerData?['phone'] ?? '',
          'skills': workerData?['skills'] ?? '',
          'education': workerData?['education'] ?? '',
          'region': workerData?['region'] ?? '',
        },
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Чат успешно создан!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(chatId: chatId),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Закрываем индикатор
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.workerData;

    final name = data['name'] ?? "Без имени";
    final email = data['email'] ?? "—";
    final exp = data['experience'] ?? "—";
    final uid = data['userId'] ?? data['uid'] ?? "";

    ImageProvider? avatar;
    if (data['avatarUrl'] != null && data['avatarUrl'].isNotEmpty) {
      try {
        avatar = MemoryImage(base64Decode(data['avatarUrl']));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: bg,

      body: CustomScrollView(
        slivers: [

          /// ШАПКА
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: primaryDark,
            iconTheme: IconThemeData(color: accentOrange),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryDark, Colors.black87],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: avatar,
                      backgroundColor: Colors.white,
                      child: avatar == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),

          /// КОНТЕНТ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  _infoCard([
                    _infoRow(Icons.work, "Опыт", exp),
                    _infoRow(Icons.email, "Email", email),
                  ]),

                  const SizedBox(height: 16),

                  /// РЕЗЮМЕ
                  _card(
                    child: ListTile(
                      leading: Icon(Icons.description, color: accentOrange),
                      title: const Text("Резюме"),
                      subtitle: Text(data['resumeName'] ?? "Нет файла"),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDark,
                        ),
                        onPressed: () {},
                        child: const Text("Открыть"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// КНОПКИ: НАПИСАТЬ И ОТЗЫВЫ
                  Row(
                    children: [
                      // Кнопка "Написать"
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.chat),
                          label: const Text(
                            "Написать",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Кнопка "Оставить отзыв"
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openReviewSheet(uid),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentOrange,
                            side: BorderSide(color: accentOrange),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.star_border, color: accentOrange),
                          label: const Text(
                            "Оставить отзыв",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ЗАГОЛОВОК ОТЗЫВОВ
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Отзывы",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 8),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('reviews')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const CircularProgressIndicator();

                      final docs = snap.data!.docs;

                      if (docs.isEmpty) {
                        return const Card(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text("Пока нет отзывов"),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: docs.map((d) {
                          final r = d.data() as Map<String, dynamic>;
                          final rating = r['rating'] ?? 5;

                          String date = "";
                          if (r['createdAt'] != null) {
                            date = DateFormat('dd.MM.yyyy')
                                .format((r['createdAt'] as Timestamp).toDate());
                          }

                          return _card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(r['reviewerName'] ?? "Аноним",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(date,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: List.generate(
                                      5,
                                      (i) => Icon(
                                            i < rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 16,
                                            color: accentOrange,
                                          )),
                                ),
                                const SizedBox(height: 8),
                                Text(r['text'] ?? ""),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _infoCard(List<Widget> children) {
    return _card(
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}