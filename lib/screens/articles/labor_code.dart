import 'package:flutter/material.dart';

class LaborCodePage extends StatelessWidget {
  const LaborCodePage({super.key});

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
        title: Text("ТК Республики Беларусь", style: TextStyle(color: primaryDark, fontSize: 14)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel, color: accentOrange, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Изменения ТК РБ для стройки",
                    style: TextStyle(color: primaryDark, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildTag("Законодательство РБ"),
            const SizedBox(height: 25),

            _buildSectionTitle("Вахтовый метод и разъездной характер"),
            _buildParagraph("С 2024 года уточнены нормы компенсаций. Для строителей в РБ выплата компенсации за подвижной характер работы обязательна, если объект находится вне места жительства. Проверьте актуальные нормы суточных по РБ."),

            _buildSectionTitle("Охрана труда и аттестация"),
            _buildParagraph("Усилен контроль за допуском на объект. Без прохождения вводного инструктажа и проверки знаний по вопросам охраны труда (обучение в РБ каждые 1-3 года для разных категорий) допуск рабочих грозит приостановкой деятельности объекта."),

            _buildWarningCard("Важно: В Беларуси введена обязательная сертификация и аттестация не только компаний, но и отдельных специалистов (мастеров, прорабов) в «Белстройцентре»."),

            _buildSectionTitle("Контрактная система"),
            _buildParagraph("Напоминаем, что в РБ минимальный срок контракта — 1 год. При продлении контракта с добросовестным строителем на максимальный срок (5 лет) теперь применяются дополнительные меры стимулирования (надбавка к окладу и доп. отпуск)."),

            const SizedBox(height: 30),
            
            Text("Чек-лист для застройщика РБ:", style: TextStyle(color: primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildCheckItem("Проверить аттестаты соответствия «Белстройцентра»."),
            _buildCheckItem("Оформить страховку от несчастных случаев в «Белгосстрах»."),
            _buildCheckItem("Убедиться, что СИЗ соответствуют нормам ТНПА РБ."),
            
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
        border: Border.all(color: accentOrange.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: accentOrange, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(color: primaryDark, fontSize: 19, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.5),
    );
  }

  Widget _buildWarningCard(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: const Border(
          left: BorderSide(color: Colors.red, width: 4),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF664D03), fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: accentOrange, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
