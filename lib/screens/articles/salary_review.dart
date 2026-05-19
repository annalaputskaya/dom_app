import 'package:flutter/material.dart';

class SalaryReviewPage extends StatelessWidget {
  const SalaryReviewPage({super.key});

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
        title: Text("Аналитика стройки РБ", style: TextStyle(color: primaryDark, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Зарплаты в строительстве РБ 2024-2025",
              style: TextStyle(color: primaryDark, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildTag("Рынок Беларуси"),
            const SizedBox(height: 25),

            _buildParagraph("В Беларуси наблюдается рост зарплат в частном секторе строительства. Основной тренд — переход на сдельную оплату за объем (аккорд) и вахтовый метод внутри страны."),

            const SizedBox(height: 20),
            
            // Статистика по РБ
            Row(
              children: [
                _buildStatCard("Минск", "+20%", "рост ставок"),
                const SizedBox(width: 12),
                _buildStatCard("Регионы", "+15%", "рост ставок"),
              ],
            ),

            _buildSectionTitle("Средний доход за месяц (чистыми)"),
            
            _buildSalaryRow("Монолитчик (бетонщик)", "2 800 – 4 500 BYN"),
            _buildSalaryRow("Каменщик (блок, кирпич)", "3 000 – 5 000 BYN"),
            _buildSalaryRow("Отделочник-универсал", "2 500 – 4 000 BYN"),
            _buildSalaryRow("Электромонтажник", "2 200 – 3 500 BYN"),
            _buildSalaryRow("Подсобный рабочий", "1 500 – 2 000 BYN"),

            const SizedBox(height: 20),

            _buildSectionTitle("Что требуют строители в РБ?"),
            _buildParagraph("Помимо базовой ставки, для удержания бригад в Беларуси критичны:"),
            const SizedBox(height: 12),
            _buildBenefitItem(Icons.home_work_outlined, "Оплата жилья (съемные квартиры)"),
            _buildBenefitItem(Icons.plumbing_outlined, "Профессиональный инструмент"), 
            _buildBenefitItem(Icons.airport_shuttle_outlined, "Компенсация проезда до объекта"), 


            const SizedBox(height: 30),
            
            // Специфика РБ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Важно: В РБ растет спрос на официальное оформление по договору подряда с сохранением социальных гарантий, что становится конкурентным преимуществом работодателя.",
                style: TextStyle(color: Colors.white, height: 1.5, fontSize: 14),
              ),
            ),
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

  Widget _buildStatCard(String title, String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentOrange)),
            Text(sub, style: const TextStyle(fontSize: 10, color: Colors.black38)),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryRow(String job, String money) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(job, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          Text(money, style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 15),
      child: Text(title, style: TextStyle(color: primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(text, style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.6));
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentOrange, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
