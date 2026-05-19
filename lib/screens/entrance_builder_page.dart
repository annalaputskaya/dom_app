import 'package:flutter/material.dart';
import 'builder_register_page.dart';
import 'login_bld_page.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryDark = const Color(0xFFC5BAAA);
    final Color accentOrange = const Color(0xFFF08A08);

    return Scaffold(
      backgroundColor: primaryDark,

      body: Stack(
        children: [

          /// 🔙 КНОПКА НАЗАД
          Positioned(
            top: 20,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF2C2C2C),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          /// ОСНОВНОЙ КОНТЕНТ
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [

                  const Spacer(),

                  /// 🏗 КАРТИНКА
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2C2C2C).withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.construction,
                      size: 100,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ЗАГОЛОВОК
                  const Text(
                    "Добро пожаловать в MasterOK",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ПОДЗАГОЛОВОК
                  const Text(
                    "Ищите работу быстро и удобно",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),

                  const Spacer(),

                  /// 🔥 КНОПКА 1 (регистрация)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BuilderRegisterPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Я новый пользователь",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ✅ КНОПКА 2 (ВХОД)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginBldPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2C2C2C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "У меня уже есть аккаунт",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}