import 'package:flutter/material.dart';
// Импортируй свои файлы (проверь правильность путей)
import 'articles/ideal_vacancy.dart';
import 'articles/labor_code.dart';
import 'articles/salary_review.dart';
import 'articles/case_retention.dart';
import 'articles/law_migrants.dart';

class EmployerArticlesPage extends StatefulWidget {
  const EmployerArticlesPage({super.key});

  @override
  State<EmployerArticlesPage> createState() => _EmployerArticlesPageState();
}

class _EmployerArticlesPageState extends State<EmployerArticlesPage> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);
  final Color bgLight = const Color(0xFFF8FAFC);

  String selectedCategory = "Все";
  final List<String> categories = ["Все", "Найм", "Право", "Зарплаты", "Кейсы"];

  // Добавили поле "page" с классом страницы
  final List<Map<String, dynamic>> allArticles = [
    {
      "title": "Как составить идеальную вакансию",
      "tag": "Найм",
      "icon": Icons.edit_note,
      "page": const IdealVacancyPage(), 
    },
    {
      "title": "Изменения в Трудовом кодексе 2026",
      "tag": "Право",
      "icon": Icons.gavel,
      "page": const LaborCodePage(),
    },
    {
      "title": "Обзор зарплат синих воротничков",
      "tag": "Зарплаты",
      "icon": Icons.trending_up,
      "page": const SalaryReviewPage(),
    },
    {
      "title": "Как удержать лучших сотрудников без повышения ЗП",
      "tag": "Кейсы",
      "icon": Icons.people_outline,
      "page": const CaseRetentionPage(),
    },
    {
      "title": "Оформление иностранных граждан",
      "tag": "Право",
      "icon": Icons.badge,
      "page": const LawMigrantsPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredArticles = selectedCategory == "Все"
        ? allArticles
        : allArticles.where((article) => article['tag'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80.0, 
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryDark,
            iconTheme: IconThemeData(color: accentOrange),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Статьи и советы", 
                style: TextStyle(color: accentOrange, fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) => setState(() => selectedCategory = cat),
                      selectedColor: accentOrange,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : primaryDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: isSelected ? accentOrange : Colors.black12),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final article = filteredArticles[index];
                  return _buildArticleCard(
                    context, // Передаем контекст для навигации
                    article['title'],
                    article['tag'],
                    article['icon'],
                    article['page'], // Передаем страницу
                  );
                },
                childCount: filteredArticles.length,
              ),
            ),
          ),         
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, String title, String tag, IconData icon, Widget targetPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: accentOrange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tag.toUpperCase(), style: TextStyle(color: accentOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title, style: TextStyle(color: primaryDark, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black12),
          ],
        ),
      ),
    );
  }
}
