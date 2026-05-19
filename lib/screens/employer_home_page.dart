  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'yandex_workers_map.dart'; 
  import 'worker_filters_page.dart';
  import 'job_form_page.dart';
  import 'advice_page.dart';
  import 'worker_detail_page.dart';
  import 'edit_employer_profile_page.dart';
  import 'chat_page.dart'; 

  class EmployerHomePage extends StatefulWidget {
    const EmployerHomePage({super.key});

    @override
    State<EmployerHomePage> createState() => _EmployerHomePageState();
  }

  class _EmployerHomePageState extends State<EmployerHomePage> {
    int _selectedIndex = 0;

    final Color primaryDark = const Color(0xFF1A2238);
    final Color accentOrange = const Color(0xFFF08A08);
    final Color bgLight = const Color(0xFFF4F7FA);

    late final List<Widget> _pages;

    @override
    void initState() {
      super.initState();
      _pages = [
        const EmployerMainSection(),
        const EmployerJobsSection(),
        const EmployerChatsSection(),
        const EmployerProfileSection(),
      ];
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: bgLight,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: primaryDark,
          selectedItemColor: accentOrange,
          unselectedItemColor: Colors.white60,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Объявления'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Сообщения'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          ],
        ),
      );
    }
  }

  // =============================================================================
  // ГЛАВНАЯ СТРАНИЦА
  // =============================================================================

  class EmployerMainSection extends StatefulWidget {
    const EmployerMainSection({super.key});

    @override
    State<EmployerMainSection> createState() => _EmployerMainSectionState();
  }

  class _EmployerMainSectionState extends State<EmployerMainSection> {
    final Color primaryDark = const Color(0xFF1A2238);
    final Color accentOrange = const Color(0xFFF08A08);
    
    Map<String, dynamic>? _currentFilters;
    final TextEditingController _searchController = TextEditingController();
    String _searchQuery = "";
    
    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }
    
    void _applyFilters(Map<String, dynamic> filters) {
      setState(() {
        _currentFilters = filters;
      });
    }
    
    void _onSearchChanged(String query) {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
    }

    @override
    Widget build(BuildContext context) {
      return SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Поиск специалистов",
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: accentOrange),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FiltersPage(),
                          ),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          _applyFilters(result);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            if (_currentFilters != null && _hasActiveFilters())
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        "Активные фильтры: ",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      ..._buildActiveFiltersChips(),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentFilters = null;
                            _searchController.clear();
                            _searchQuery = "";
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text("Сбросить все", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  SizedBox(
                    height: 130,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _buildSquareCard(
                          text: "Специалисты\nрядом",
                          icon: Icons.location_on,
                          color: Colors.blue,
                          orange: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const YandexWorkersMapPage(),
                              ),
                            );
                          },
                        ),
                        _buildSquareCard(
                          text: "Полезные статьи\nи советы",
                          icon: Icons.lightbulb,
                          color: Colors.amber,
                          orange: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmployerArticlesPage(),
                              ),
                            );
                          },
                        ),
                        _buildSquareCard(
                          text: "Добавить\nобъявление",
                          icon: Icons.add_box,
                          color: Colors.white,
                          orange: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateJobPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text(
                      "Рекомендуемые резюме",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDark),
                    ),
                  ),
                  
                  StreamBuilder<QuerySnapshot>(
                    stream: _getFilteredWorkersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("Специалисты не найдены"),
                          ),
                        );
                      }
                      
                      final usersDocs = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: usersDocs.length,
                        itemBuilder: (context, index) {
                          final data = usersDocs[index].data() as Map<String, dynamic>;
                          if (!_matchesSearchAndFilters(data)) {
                            return const SizedBox.shrink();
                          }
                          
                          // Используем поле name (полное имя)
                          final String name = data['name'] ?? "Без имени";
                          final String job = data['profession'] ?? "Специалист";
                          final String exp = data['experience'] ?? "Не указан";
                          final String? avatarBase64 = data['avatarUrl'];
                          
                          return _buildResumeCard(
                            context,
                            name,
                            job,
                            exp,
                            avatarBase64,
                            data,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    Stream<QuerySnapshot> _getFilteredWorkersStream() {
      return FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'builder')
          .snapshots();
    }
    
    bool _matchesSearchAndFilters(Map<String, dynamic> worker) {
      if (_searchQuery.isNotEmpty) {
        final name = (worker['name'] ?? "").toLowerCase();
        final profession = (worker['profession'] ?? "").toLowerCase();
        final experience = (worker['experience'] ?? "").toLowerCase();
        final skills = (worker['skills'] ?? "").toLowerCase();
        
        if (!name.contains(_searchQuery) &&
            !profession.contains(_searchQuery) &&
            !experience.contains(_searchQuery) &&
            !skills.contains(_searchQuery)) {
          return false;
        }
      }
      
      if (_currentFilters == null) return true;
      
      if (_currentFilters!['job'] != null && _currentFilters!['job'].toString().isNotEmpty) {
        final jobFilter = _currentFilters!['job'].toString().toLowerCase();
        final workerProfession = (worker['profession'] ?? "").toLowerCase();
        if (!workerProfession.contains(jobFilter)) return false;
      }
      
      if (_currentFilters!['keywords'] != null && _currentFilters!['keywords'].toString().isNotEmpty) {
        final keywords = _currentFilters!['keywords'].toString().toLowerCase();
        final workerSkills = (worker['skills'] ?? "").toLowerCase();
        if (!workerSkills.contains(keywords)) return false;
      }
      
      if (_currentFilters!['experience'] != null && _currentFilters!['experience'].toString().isNotEmpty) {
        final expFilter = _currentFilters!['experience'].toString();
        final workerExp = worker['experience'] ?? "";
        if (!_matchesExperience(workerExp.toString(), expFilter)) return false;
      }
      
      if (_currentFilters!['education'] != null && _currentFilters!['education'].toString().isNotEmpty) {
        final eduFilter = _currentFilters!['education'].toString();
        final workerEdu = worker['education'] ?? "";
        if (!_matchesEducation(workerEdu.toString(), eduFilter)) return false;
      }
      
      if (_currentFilters!['regions'] != null && _currentFilters!['regions'] is List) {
        final regions = _currentFilters!['regions'] as List;
        if (regions.isNotEmpty) {
          final workerRegion = worker['region'] ?? worker['location'] ?? "Минск";
          if (!regions.contains(workerRegion)) return false;
        }
      }
      
      return true;
    }
    
    bool _matchesExperience(String workerExp, String filterExp) {
      final match = RegExp(r'(\d+)').firstMatch(workerExp);
      if (match == null) return filterExp == "0";
      final years = int.tryParse(match.group(1)!) ?? 0;
      switch (filterExp) {
        case "0": return years == 0;
        case "1-3": return years >= 1 && years <= 3;
        case "3-6": return years >= 3 && years <= 6;
        case "6+": return years >= 6;
        default: return true;
      }
    }
    
    bool _matchesEducation(String workerEdu, String filterEdu) {
      final edu = workerEdu.toLowerCase();
      switch (filterEdu) {
        case "none": return edu.contains("не требуется") || edu.contains("нет") || edu.contains("среднее");
        case "high": return edu.contains("высшее");
        case "mid": return edu.contains("среднее проф") || edu.contains("техникум") || edu.contains("колледж");
        default: return true;
      }
    }
    
    bool _hasActiveFilters() {
      if (_currentFilters == null) return false;
      return (_currentFilters!['job'] != null && _currentFilters!['job'].toString().isNotEmpty) ||
            (_currentFilters!['keywords'] != null && _currentFilters!['keywords'].toString().isNotEmpty) ||
            (_currentFilters!['regions'] != null && (_currentFilters!['regions'] as List).isNotEmpty) ||
            (_currentFilters!['experience'] != null && _currentFilters!['experience'].toString().isNotEmpty) ||
            (_currentFilters!['education'] != null && _currentFilters!['education'].toString().isNotEmpty);
    }
    
    List<Widget> _buildActiveFiltersChips() {
      final List<Widget> chips = [];
      if (_currentFilters!['job'] != null && _currentFilters!['job'].toString().isNotEmpty) {
        chips.add(Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            label: Text("Должность: ${_currentFilters!['job']}"),
            backgroundColor: accentOrange.withOpacity(0.2),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              setState(() {
                _currentFilters!['job'] = "";
              });
            },
          ),
        ));
      }
      return chips;
    }
    
    Widget _buildSquareCard({
      required String text,
      required IconData icon,
      required Color color,
      required bool orange,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 130,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: orange ? accentOrange : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: orange ? Colors.white : color, size: 28),
              Text(
                text,
                style: TextStyle(
                  color: orange ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    Widget _buildResumeCard(
      BuildContext context,
      String name,
      String job,
      String exp,
      String? avatarBase64,
      Map<String, dynamic> fullData,
    ) {
      ImageProvider? avatarProvider;
      if (avatarBase64 != null && avatarBase64.isNotEmpty) {
        try {
          avatarProvider = MemoryImage(base64Decode(avatarBase64));
        } catch (_) {}
      }
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? Icon(Icons.person, size: 30, color: Colors.grey.shade400)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text("Стаж: ", style: TextStyle(color: accentOrange, fontWeight: FontWeight.bold)),
                Text(exp),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text("Минск", style: TextStyle(color: Colors.grey.shade600)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkerDetailPage(workerData: fullData),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Подробнее"),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  // =============================================================================
  // МОИ ОБЪЯВЛЕНИЯ
  // =============================================================================

  class EmployerJobsSection extends StatelessWidget {
    const EmployerJobsSection({super.key});

    @override
    Widget build(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser;

      const Color primaryDark = Color(0xFF1A2238);
      const Color accentOrange = Color(0xFFF08A08);
      const Color bgLight = Color(0xFFF4F7FA);

      return Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Мои объявления",
            style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: user == null
            ? const Center(child: Text("Вы не авторизованы"))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .where('userId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_outline, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 20),
                          Text(
                            "У вас пока нет объявлений",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Создайте первое объявление\nи найдите специалистов",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }

                  final jobs = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final doc = jobs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final title = data['title'] ?? "Без названия";
                      final description = data['description'] ?? "";
                      final priceRaw = data['price'] ?? "";
                      final location = data['location'] ?? "Минск";

                      String cleanPrice = priceRaw.toString().trim();
                      cleanPrice = cleanPrice.replaceAll('₽', '').replaceAll('руб', '').trim();
                      
                      String displayPrice = "";
                      if (cleanPrice.isEmpty) {
                        displayPrice = "Договорная";
                      } else if (cleanPrice.toLowerCase().contains("договор")) {
                        displayPrice = "Договорная";
                      } else {
                        displayPrice = "$cleanPrice ₽";
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: accentOrange.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.work_outline, color: accentOrange),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDark),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(height: 1.5, fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 5),
                                Text(location, style: TextStyle(color: Colors.grey.shade600)),
                                const Spacer(),
                                Text(
                                  displayPrice,
                                  style: TextStyle(color: accentOrange, fontSize: 22, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                    foregroundColor: Colors.red,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance.collection('jobs').doc(doc.id).delete();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Объявление удалено")),
                                      );
                                    }
                                  },
                                  child: const Text("Удалить", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ),
                              ),
                            ),
                          ],
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
  // ЧАТЫ РАБОТОДАТЕЛЯ
  // =============================================================================

  class EmployerChatsSection extends StatelessWidget {
    const EmployerChatsSection({super.key});

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
            style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold),
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

                final workerData = chat['workerData'] as Map<String, dynamic>?;
                
                // Используем поле name из workerData
                String workerName = "Строитель";
                
                if (workerData != null) {
                  workerName = workerData['name'] ?? "Строитель";
                } else {
                  workerName = chat['workerName'] ?? "Строитель";
                }

                final String? workerAvatar = workerData?['avatarUrl'];
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
                      backgroundImage: workerAvatar != null && workerAvatar.isNotEmpty
                          ? MemoryImage(base64Decode(workerAvatar))
                          : null,
                      child: workerAvatar == null || workerAvatar.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      workerName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: primaryDark),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                    onLongPress: () async {
                      final workerId = chat['workerId'];
                      if (workerId != null) {
                        // Загружаем полные данные строителя из Firestore
                        final workerDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(workerId)
                            .get();
                        
                        if (workerDoc.exists && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkerDetailPage(
                                workerData: workerDoc.data() as Map<String, dynamic>,
                              ),
                            ),
                          );
                        }
                      } else if (workerData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkerDetailPage(
                              workerData: workerData,
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
  // ПРОФИЛЬ РАБОТОДАТЕЛЯ
  // =============================================================================

  class EmployerProfileSection extends StatelessWidget {
    const EmployerProfileSection({super.key});

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
          centerTitle: true,
          title: const Text(
            "Профиль",
            style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            // Проверка на загрузку
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Проверка на наличие данных
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Данные пользователя не найдены"));
            }
            
            final data = snapshot.data!.data() as Map<String, dynamic>;
            
            // Получаем имя из поля 'name' (оно уже содержит имя + фамилию)
            final String name = data['name'] ?? 
                                data['firstName'] ?? 
                                (data['firstName'] != null && data['lastName'] != null 
                                    ? "${data['firstName']} ${data['lastName']}" 
                                    : null) ??
                                "Пользователь";

            final avatarBase64 = data['avatarUrl'];
            ImageProvider? avatarProvider;
            if (avatarBase64 != null && avatarBase64.toString().isNotEmpty) {
              try {
                avatarProvider = MemoryImage(base64Decode(avatarBase64));
              } catch (_) {}
            }

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
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: primaryDark,
                          backgroundImage: avatarProvider,
                          child: avatarProvider == null
                              ? const Icon(Icons.business, color: Colors.white, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDark)),
                              const SizedBox(height: 4),
                              Text(userEmail, style: const TextStyle(fontSize: 14, color: textSecondary)),
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
                      "Редактировать профиль",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditEmployerProfilePage()),
                        );
                      },
                    ),           
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            ),
          ],
        ),
        child: Column(children: items),
      );
    }

    Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
      return ListTile(
        leading: const Icon(Icons.edit_outlined, color: Color(0xFF1A2238), size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A2238))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
        onTap: onTap,
      );
    }
  }