import 'package:flutter/material.dart';
import 'employer_home_page.dart';

class SjbPage extends StatelessWidget {
  const SjbPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryDark = const Color(0xFF1A2238);
    final Color accentOrange = const Color(0xFFF08A08);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentOrange.withOpacity(0.12),
                ),
                child: Icon(
                  Icons.verified_rounded,
                  size: 90,
                  color: accentOrange,
                ),
              ),

              const SizedBox(height: 28),

              /// ЗАГОЛОВОК
              Text(
                "Готово!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),

              const SizedBox(height: 10),

              /// ПОДЗАГОЛОВОК
              const Text(
                "Ваше объявление успешно опубликовано!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Теперь его могут видеть мастера",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
              ),

              const SizedBox(height: 40),

              /// КНОПКА
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployerHomePage(),
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
                    "Перейти в приложение",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// МАЛЕНЬКАЯ ПОДСКАЗКА
              const Text(
                "Вы можете управлять объявлениями во вкладке объявления ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}