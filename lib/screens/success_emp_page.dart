import 'package:flutter/material.dart';
import 'employer_home_page.dart'; 

class SuccessEmpPage extends StatelessWidget {
  const SuccessEmpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryDark = const Color(0xFF1A2238);
    final Color accentOrange = const Color(0xFFF08A08);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 100, color: accentOrange),
              const SizedBox(height: 30),
              const Text(
                "Поздравляем!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A2238)),
              ),
              const SizedBox(height: 20),
              const Text(
                "Вы успешно прошли регистрацию.\nТеперь вы можете искать работников в любое время и в любом месте.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 50),
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
                      (route) => false, // Это условие закрывает все прошлые экраны
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Начнем!", 
                    style: TextStyle(color: Colors.white, fontSize: 18),
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
