import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'job_details_page.dart';
import 'profile_service.dart';
import 'edit_profile_page.dart';
import 'reviews_page.dart';
import 'chat_page.dart';
import 'chat_service.dart';
import 'employer_profile_page.dart';
import 'applications_history_page.dart';

// =============================================================================
// 🔧 СЕРВИС ДЛЯ РАБОТЫ С ИЗБРАННЫМ
// =============================================================================
class FavoritesService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _userId => _auth.currentUser?.uid;
  static bool get isUserAuthenticated => _auth.currentUser != null;

  static Future<bool?> toggleFavorite(String jobId, Map<String, dynamic> jobData) async {
    if (!isUserAuthenticated) {
      debugPrint('❌ toggleFavorite: пользователь не авторизован');
      return null;
    }
    
    final userId = _userId;
    if (userId == null) return null;
    if (jobId.isEmpty) return null;

    try {
      final favoritesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites');
      
      final docRef = favoritesRef.doc(jobId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
        return false;
      } else {
        await docRef.set({
          'jobId': jobId,
          'title': jobData['title'] ?? '',
          'price': jobData['price'] ?? '',
          'priceType': jobData['priceType'] ?? '',
          'isNegotiable': jobData['isNegotiable'] ?? false,
          'location': jobData['location'] ?? '',
          'category': jobData['category'] ?? '',
          'authorName': jobData['name'] ?? '',
          'addedAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (e) {
      debugPrint('❌ Ошибка toggleFavorite: $e');
      return null;
    }
  }

  static Stream<bool> isFavoriteStream(String jobId) {
    if (!isUserAuthenticated) return Stream.value(false);
    final userId = _userId;
    if (userId == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(jobId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getFavoritesStream() {
    if (!isUserAuthenticated) {
      return _firestore.collection('_dummy').limit(0).snapshots();
    }
    final userId = _userId;
    if (userId == null) {
      return _firestore.collection('_dummy').limit(0).snapshots();
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}

// =============================================================================
// 🏠 ГЛАВНАЯ СТРАНИЦА СТРОИТЕЛЯ
// =============================================================================
class BuilderHomePage extends StatefulWidget {
  const BuilderHomePage({super.key});

  @override
  State<BuilderHomePage> createState() => _BuilderHomePageState();
}

class _BuilderHomePageState extends State<BuilderHomePage> {
  int _selectedIndex = 0;

  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);
  final Color bgLight = const Color(0xFFF4F7FA);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const JobFeedSection(),
      const FavoritesSection(),
      const ChatsSection(),
      const ProfileSection(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: primaryDark,
        selectedItemColor: accentOrange,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Избранные'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Сообщения'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
        ],
      ),
    );
  }
}

// =============================================================================
// 🔍 ВКЛАДКА 1: ЛЕНТА ВАКАНСИЙ
// =============================================================================
class JobFeedSection extends StatefulWidget {
  const JobFeedSection({super.key});

  @override
  State<JobFeedSection> createState() => _JobFeedSectionState();
}

class _JobFeedSectionState extends State<JobFeedSection> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);
  
  // Контроллер для поиска
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
  }

  // Проверка соответствия вакансии поисковому запросу
  bool _matchesSearch(Map<String, dynamic> job) {
    if (_searchQuery.isEmpty) return true;
    
    final title = (job['title'] ?? "").toLowerCase();
    final description = (job['description'] ?? "").toLowerCase();
    final location = (job['location'] ?? "").toLowerCase();
    final authorName = (job['name'] ?? "").toLowerCase();
    
    return title.contains(_searchQuery) ||
           description.contains(_searchQuery) ||
           location.contains(_searchQuery) ||
           authorName.contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeaderSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Пока нет вакансий"));
                }
                
                final allJobs = snapshot.data!.docs;
                
                // Фильтруем вакансии по поисковому запросу
                final filteredJobs = allJobs.where((doc) {
                  final jobData = doc.data() as Map<String, dynamic>;
                  return _matchesSearch(jobData);
                }).toList();
                
                if (filteredJobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          "Ничего не найдено",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Попробуйте изменить поисковый запрос",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final jobDoc = filteredJobs[index];
                    final jobData = jobDoc.data() as Map<String, dynamic>;
                    final jobId = jobDoc.id;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailsPage(job: jobData),
                          ),
                        );
                      },
                      child: _buildJobCard(jobData, jobId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Поиск работы...",
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: accentOrange),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(String jobId, Map<String, dynamic> jobData) {
    return StreamBuilder<bool>(
      stream: FavoritesService.isFavoriteStream(jobId),
      builder: (context, snapshot) {
        final isFavorited = snapshot.data ?? false;
        
        return IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.grey.shade400,
          ),
          onPressed: () async {
            if (!FavoritesService.isUserAuthenticated) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔐 Необходимо войти в аккаунт'),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              return;
            }
            
            final result = await FavoritesService.toggleFavorite(jobId, jobData);
            
            if (context.mounted) {
              if (result == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Ошибка. Попробуйте ещё раз'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result ? '✅ Добавлено в избранное' : '❌ Удалено из избранного'),
                    backgroundColor: result ? Colors.green : Colors.grey[800],
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, String jobId) {
    final bool isNegotiable = job["isNegotiable"] ?? false;
    final String price = job["price"] ?? "";
    final String priceType = job["priceType"] ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job["title"] ?? "Без названия",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isNegotiable
                          ? "Договорная цена"
                          : "$price ₽ $priceType",
                      style: TextStyle(
                        color: accentOrange,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildFavoriteButton(jobId, job),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            job["name"] ?? "Неизвестный автор",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Divider(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job["location"] ?? "Локация не указана",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () async {
                    final currentUser = FirebaseAuth.instance.currentUser;

                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Необходимо войти в аккаунт"),
                        ),
                      );
                      return;
                    }

                    final String? ownerId = job['userId'];

                    if (ownerId == null || ownerId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ошибка: автор объявления не найден"),
                        ),
                      );
                      return;
                    }

                    if (ownerId == currentUser.uid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Это ваше объявление"),
                        ),
                      );
                      return;
                    }

                    // Показываем диалог подтверждения
                    final bool? shouldCreateChat = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Подтверждение"),
                        content: const Text("Вы хотите откликнуться на эту вакансию?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Отмена"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryDark,
                            ),
                            child: const Text("Да, откликнуться"),
                          ),
                        ],
                      ),
                    );

                    if (shouldCreateChat != true) return;

                    // Проверяем, существует ли уже чат
                    final existingChats = await FirebaseFirestore.instance
                        .collection('chats')
                        .where('jobId', isEqualTo: jobId)
                        .where('participants', arrayContains: currentUser.uid)
                        .get();

                    String chatId = '';

                    if (existingChats.docs.isNotEmpty) {
                      final existingChat = existingChats.docs.first;
                      final data = existingChat.data();
                      final participants = List<String>.from(data['participants'] ?? []);
                      
                      if (participants.contains(ownerId)) {
                        chatId = existingChat.id;
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Чат уже существует, переходим в него..."),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(chatId: chatId),
                            ),
                          );
                        }
                        return;
                      }
                    }

                    // Получаем данные работодателя
                    final employerDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(ownerId)
                        .get();
                    
                    final employerData = employerDoc.data();
                    
                    // Получаем данные текущего пользователя
                    final workerDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .get();
                    
                    final workerData = workerDoc.data();

                    final String workerName = workerData?['name'] ?? 'Строитель';
                    final String employerName = employerData?['name'] ?? job['name'] ?? 'Работодатель';

                    chatId = await ChatService.createOrGetChat(
                      otherUserId: ownerId,
                      jobId: jobId,
                      jobTitle: job['title'] ?? '',
                      jobPrice: job['price']?.toString() ?? '',
                      jobPriceType: job['priceType'] ?? '',
                      jobLocation: job['location'] ?? '',
                      employerData: {
                        'userId': ownerId,
                        'name': employerName,
                        'avatarUrl': employerData?['avatarUrl'] ?? '',
                        'email': employerData?['email'] ?? '',
                        'phone': employerData?['phone'] ?? '',
                      },
                      workerData: {
                        'userId': currentUser.uid,
                        'name': workerName,
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Откликнуться",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ❤️ ВКЛАДКА 2: ИЗБРАННОЕ
// =============================================================================
class FavoritesSection extends StatefulWidget {
  const FavoritesSection({super.key});

  @override
  State<FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);

  @override
  Widget build(BuildContext context) {
    if (!FavoritesService.isUserAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Избранные вакансии",
            style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "🔐 Необходимо войти в аккаунт",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                "Чтобы видеть избранные вакансии,\nвойдите или зарегистрируйтесь",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.login),
                label: const Text("Войти в аккаунт"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Избранные вакансии",
          style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FavoritesService.getFavoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Пока нет избранных вакансий",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Нажмите на ❤️ в карточке, чтобы добавить",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final favorites = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favData = favorites[index].data() as Map<String, dynamic>;
              final jobId = favData['jobId'] as String;
              return InkWell(
                onTap: () async {
                  final jobDoc = await FirebaseFirestore.instance
                      .collection('jobs')
                      .doc(jobId)
                      .get();
                  if (jobDoc.exists && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailsPage(job: jobDoc.data()!),
                      ),
                    );
                  }
                },
                child: _buildFavoriteCard(favData, jobId),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> fav, String jobId) {
    final bool isNegotiable = fav["isNegotiable"] ?? false;
    final String price = fav["price"] ?? "";
    final String priceType = fav["priceType"] ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fav["title"] ?? "Без названия",
                      style: TextStyle(
                        color: primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNegotiable ? "Договорная цена" : "$price ₽ $priceType",
                      style: TextStyle(
                        color: accentOrange,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<bool>(
                stream: FavoritesService.isFavoriteStream(jobId),
                builder: (context, snapshot) {
                  final isFavorited = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.grey.shade400,
                    ),
                    onPressed: () async {
                      if (!FavoritesService.isUserAuthenticated) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🔐 Необходимо войти в аккаунт'),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        return;
                      }
                      
                      final result = await FavoritesService.toggleFavorite(jobId, fav);
                      if (context.mounted && result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result ? '✅ Добавлено в избранное' : '❌ Удалено из избранного'),
                            backgroundColor: result ? Colors.green : Colors.grey[800],
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                fav["location"] ?? "Локация не указана",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 💬 ВКЛАДКА 3: ЧАТЫ
// =============================================================================
class ChatsSection extends StatelessWidget {
  const ChatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    const Color primaryDark = Color(0xFF1A2238);
    const Color accentOrange = Color(0xFFF08A08);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Необходимо войти")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Сообщения",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("Чатов пока нет"));
          }

          chats.sort((a, b) {
            final aTime = (a['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime(1970);
            final bTime = (b['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime(1970);
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final doc = chats[index];
              final chat = doc.data() as Map<String, dynamic>;

              final employerData = chat['employerData'] as Map<String, dynamic>?;
              
              String employerName = "Работодатель";
              if (employerData != null) {
                employerName = employerData['name'] ?? chat['employerName'] ?? "Работодатель";
              } else {
                employerName = chat['employerName'] ?? "Работодатель";
              }
              
              final String? employerAvatar = employerData?['avatarUrl'];
              final String lastMessage = chat['lastMessage'] ?? "Сообщений нет";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: accentOrange,
                    backgroundImage: employerAvatar != null && employerAvatar.isNotEmpty
                        ? MemoryImage(base64Decode(employerAvatar))
                        : null,
                    child: employerAvatar == null || employerAvatar.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    employerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(chatId: doc.id),
                      ),
                    );
                  },
                  onLongPress: () {
                    if (employerData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmployerProfilePage(
                            userId: employerData['userId'] ?? chat['employerId'],
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =============================================================================
// 👤 ВКЛАДКА 4: ПРОФИЛЬ
// =============================================================================
class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryDark = Color(0xFF1A2238);
    const Color textSecondary = Color(0xFF64748B);

    final user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "Почта не указана";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Мой профиль",
          style: TextStyle(
              color: primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: ProfileService.getProfile(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;

          final name = data?['name'] ?? "Строитель";
          final avatar = data?['avatarUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: primaryDark,
                        backgroundImage: avatar != null && avatar.isNotEmpty
                            ? MemoryImage(base64Decode(avatar))
                            : null,
                        child: avatar == null || avatar.isEmpty
                            ? const Icon(Icons.person, color: Colors.white, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileMenu([
                  _buildMenuItem(
                      Icons.edit_outlined,
                      "Редактировать профиль", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfilePage()),
                    );
                  }),
                  _buildMenuItem(Icons.history,
                      "История откликов", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ApplicationsHistoryPage(),
                          ),
                        );
                      }),
                  _buildMenuItem(Icons.star_outline, "Мой рейтинг", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReviewsPage()),
                    );
                  }),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      foregroundColor: Colors.redAccent,
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/onboarding');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      "Выйти из аккаунта",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }  

  Widget _buildProfileMenu(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A2238), size: 22),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A2238)),
      ),
      trailing: const Icon(Icons.chevron_right,
          color: Color(0xFF64748B), size: 20),
      onTap: onTap,
    );
  }
}