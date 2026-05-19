import 'package:flutter/material.dart';

class CaseRetentionPage extends StatelessWidget {
  const CaseRetentionPage({super.key});

  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Опыт компаний РБ", style: TextStyle(color: primaryDark, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Как удержать бригаду без бесконечного роста зарплат",
              style: TextStyle(color: primaryDark, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildTag("Кейсы для стройки"),
            const SizedBox(height: 25),

            _buildParagraph("На белорусском рынке стройки сейчас дефицит кадров, и мастера часто уезжают на заработки в ЕС или РФ. Однако деньги — не единственный фактор. Стабильность и условия труда в РБ могут стать решающим преимуществом."),

            _buildSectionTitle("1. Инструмент и оснастка"),
            _buildParagraph("Профессионалы ненавидят работать «убитым» инструментом. Закупка качественных перфораторов, лазерных нивелиров и удобных лесов удерживает мастеров лучше, чем разовая премия. Люди ценят свой труд и время."),

            _buildSectionTitle("2. Культура быта на объекте"),
            _buildParagraph("Чистая бытовка с обогревом, место для переодевания, микроволновка и возможность принять душ после смены. В Беларуси многие подрядчики на этом экономят, поэтому создание нормальных условий выделяет вас среди конкурентов."),

            _buildInfoBox("Совет прорабу: В стройке «сарафанное радио» работает мгновенно. Один конфликт из-за условий проживания может лишить вас притока новых кадров на весь сезон."),

            _buildSectionTitle("3. Своевременность выплат"),
            _buildParagraph("В РБ стабильность ценится выше, чем высокий, но нестабильный доход. «Честный расчет» точно в срок (например, каждые 2 недели) создает репутацию надежного нанимателя, от которого не уходят."),

            const SizedBox(height: 30),
            
            Text("Топ-3 фактора лояльности в РБ:", style: TextStyle(color: primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.handyman_outlined, "Новая спецодежда и СИЗ"),
            _buildFeatureItem(Icons.home_outlined, "Организация питания/проезда"),
            _buildFeatureItem(Icons.assignment_turned_in_outlined, "Официальный стаж и страховка"),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: accentOrange, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(title, style: TextStyle(color: primaryDark, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(text, style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.6));
  }

  Widget _buildInfoBox(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(color: primaryDark, fontStyle: FontStyle.italic, height: 1.5),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accentOrange.withOpacity(0.1),
            child: Icon(icon, color: accentOrange, size: 20),
          ),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
