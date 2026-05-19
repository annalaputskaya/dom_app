import 'package:flutter/material.dart';

class LawMigrantsPage extends StatelessWidget {
  const LawMigrantsPage({super.key});

  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);
  final Color bgLight = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Миграция в РБ (Стройка)", 
          style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Наем иностранных строителей в РБ",
              style: TextStyle(
                color: primaryDark, 
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                height: 1.2
              ),
            ),
            const SizedBox(height: 12),
            _buildTag("Законодательство РБ"),
            const SizedBox(height: 24),

            _buildParagraph(
              "В Республике Беларусь наем иностранцев регулируется Законом «О внешней трудовой миграции». Для строительной отрасли ключевым является получение специального разрешения в УГиМ МВД."
            ),

            _buildSectionTitle("1. Обязательные документы"),
            _buildParagraph("Для легальной работы на объекте в РБ необходимы:"),
            const SizedBox(height: 12),
            _buildCheckItem("Специальное разрешение (выдает УГиМ)"),
            _buildCheckItem("Трудовой договор (зарегистрированный в УГиМ)"),
            _buildCheckItem("Заверенный перевод паспорта"),
            _buildCheckItem("Свидетельство о регистрации в РБ"),

            _buildSectionTitle("2. Регистрация договора"),
            _buildParagraph(
              "Наниматель обязан зарегистрировать трудовой договор в подразделении по гражданству и миграции в течение 15 дней после его заключения."
            ),

            _buildAlertBox(
              "Важно: О расторжении договора нужно уведомить УГиМ в течение 3 рабочих дней. Для граждан ЕАЭС (РФ, КЗ, КР, АМ) спецразрешение не требуется."
            ),

            _buildSectionTitle("3. Ссылки на ресурсы МВД РБ"),
            const SizedBox(height: 8),
            
            _buildLinkCard(
              Icons.language, 
              "Сайт МВД РБ", 
              "Услуги по гражданству и миграции",
              "mvd.gov.by"
            ),
            
            const SizedBox(height: 12),

            _buildLinkCard(
              Icons.file_download_outlined, 
              "Бланки анкет", 
              "Образцы заявлений и анкет для УГиМ",
              "mvd.gov.by/blanki"
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
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("Право РБ", 
        style: TextStyle(color: Color(0xFF00796B), fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Text(title, 
        style: TextStyle(color: primaryDark, fontSize: 19, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(text, 
      style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.6));
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: accentOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBox(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: Colors.red, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, 
              style: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.w500, fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(IconData icon, String title, String subtitle, String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.05),
            child: Icon(icon, color: primaryDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(url, style: TextStyle(color: accentOrange, fontSize: 11, decoration: TextDecoration.underline)),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, color: Colors.black26, size: 18),
        ],
      ),
    );
  }
}
