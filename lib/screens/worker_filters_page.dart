import 'package:flutter/material.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color cardColor = Colors.white;

  // Контроллеры для очистки текста
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  String selectedExperience = ""; // Пусто по умолчанию
  String selectedEducation = "";  // Пусто по умолчанию
  List<String> selectedRegions = [];

  final List<String> regions = ["Минск", "Брест", "Гродно", "Витебск", "Гомель", "Могилев"];

  void _resetFilters() {
    setState(() {
      _jobController.clear();
      _keywordsController.clear();
      selectedExperience = "";
      selectedEducation = "";
      selectedRegions.clear();
    });
  }

  @override
  void dispose() {
    _jobController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryDark,
        elevation: 0,
        // Оранжевая стрелка назад
        iconTheme: IconThemeData(color: accentOrange), 
        title: Text(
          "Фильтры", 
          style: TextStyle(fontWeight: FontWeight.w600, color: accentOrange)
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text("Сбросить", style: TextStyle(color: Colors.white70)),
          )
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionCard(
            title: "Основная информация",
            child: Column(
              children: [
                _buildInputField("Должность", "Например: сварщик", Icons.work_outline, _jobController),
                const SizedBox(height: 16),
                _buildInputField("Ключевые слова", "Навыки, инструменты...", Icons.tag, _keywordsController),
              ],
            ),
          ),
          
          _buildSectionTitle("Регион"),
          Wrap(
            spacing: 8,
            children: regions.map((region) => _buildChip(region)).toList(),
          ),

          const SizedBox(height: 24),
          
          _buildSectionTitle("Опыт работы"),
          _buildSelectionGroup([
            _Option("Нет опыта", "0"),
            _Option("От 1 до 3 лет", "1-3"),
            _Option("От 3 до 6 лет", "3-6"),
            _Option("Более 6 лет", "6+"),
          ], selectedExperience, (val) => setState(() => selectedExperience = val)),

          const SizedBox(height: 24),

          _buildSectionTitle("Образование"),
          _buildSelectionGroup([
            _Option("Не требуется", "none"),
            _Option("Высшее", "high"),
            _Option("Среднее проф.", "mid"),
          ], selectedEducation, (val) => setState(() => selectedEducation = val)),

          const SizedBox(height: 40),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: primaryDark.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller, // Привязали контроллер
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: primaryDark.withOpacity(0.4)),
        labelStyle: TextStyle(color: primaryDark.withOpacity(0.5)),
        filled: true,
        fillColor: bgLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = selectedRegions.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          isSelected ? selectedRegions.remove(label) : selectedRegions.add(label);
        });
      },
      backgroundColor: Colors.white,
      selectedColor: accentOrange,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : primaryDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: isSelected ? accentOrange : Colors.black12),
    );
  }

  Widget _buildSelectionGroup(List<_Option> options, String groupValue, Function(String) onTap) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: options.map((opt) {
          final isSelected = opt.value == groupValue;
          return ListTile(
            onTap: () => onTap(opt.value),
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? accentOrange : Colors.black26,
            ),
            title: Text(
              opt.title,
              style: TextStyle(
                color: isSelected ? primaryDark : primaryDark.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApplyButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, {
          "job": _jobController.text.trim(),
          "keywords": _keywordsController.text.trim(),
          "regions": selectedRegions,
          "experience": selectedExperience,
          "education": selectedEducation,
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: accentOrange.withOpacity(0.4),
      ),
      child: const Text("Показать результаты", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _Option {
  final String title;
  final String value;
  _Option(this.title, this.value);
}
