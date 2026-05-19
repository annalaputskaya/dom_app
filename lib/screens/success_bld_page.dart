import 'package:flutter/material.dart';
import 'builder_home_page.dart'; // 👈 добавили импорт

class SuccessBldPage extends StatelessWidget {
  const SuccessBldPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryDark = const Color(0xFF1A2238);
    final Color accentOrange = const Color(0xFFF08A08);

    return Scaffold(
      backgroundColor: primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// ✅ ИКОНКА
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.greenAccent,
                ),
              ),

              const SizedBox(height: 30),

              /// ЗАГОЛОВОК
              const Text(
                "Регистрация успешна!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              /// ОПИСАНИЕ
              const Text(
                "Теперь вы можете находить заказы и откликаться на вакансии в MasterOK",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              /// 🚀 КНОПКА ПЕРЕХОДА
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BuilderHomePage(),
                      ),
                      (route) => false, 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Начнем!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// НАЗАД
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Вернуться назад",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}