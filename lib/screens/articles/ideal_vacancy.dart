import 'package:flutter/material.dart';

class IdealVacancyPage extends StatelessWidget {
  const IdealVacancyPage({super.key});

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
        title: Text("Советы для стройки", style: TextStyle(color: primaryDark, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Как привлечь опытных строителей",
              style: TextStyle(color: primaryDark, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                _buildTag("Найм"),
                const SizedBox(width: 10),
                _buildTag("4 мин чтения", isLight: true),
              ],
            ),
            const SizedBox(height: 30),

            _buildSectionTitle("1. Заголовок с «козырями»"),
            _buildParagraph("Строители ищут конкретную работу. Вместо «Рабочий» пишите: «Каменщик на ЖК (Кладка блока) — оплата еженедельно». Сразу укажите тип объекта."),

            _buildSectionTitle("2. Прозрачные деньги"),
            _buildBulletPoint("Указывайте реальную ставку за смену или за объем (м2/м3)."),
            _buildBulletPoint("Четко напишите сроки выплат: «Каждый вторник» или «По закрытию этапа»."),
            _buildBulletPoint("Укажите, есть ли авансы на питание."),

            _buildSectionTitle("3. Быт и инструмент"),
            _buildParagraph("Хорошего спеца волнует, чем работать и где спать. Обязательно добавьте:"),
            _buildBulletPoint("Проживание: «Вагончик на объекте» или «Хостел»."),
            _buildBulletPoint("Спецодежда и инструмент: выдаете вы или нужно свое."),
            _buildBulletPoint("Доставка до объекта (развозка)."),

            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentOrange.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.construction, color: accentOrange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Совет: На стройке лучше всего работают реальные фото объекта и бытовок. Кандидаты хотят видеть условия своими глазами.",
                      style: TextStyle(color: primaryDark, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, {bool isLight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLight ? Colors.black.withOpacity(0.05) : accentOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: isLight ? Colors.black54 : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(color: primaryDark, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.black87, fontSize: 16, height: 1.6),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: accentOrange, fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.6))),
        ],
      ),
    );
  }
}
