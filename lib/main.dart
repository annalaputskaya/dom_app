import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 1. ДОБАВЛЕН ЭТОТ ИМПОРТ
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'screens/onboarding_role_page.dart';
import 'screens/builder_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await initializeDateFormatting('ru', null); // 👈 2. ДОБАВЛЕНА ЭТА СТРОКА

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dom App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F3A8F),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingRolePage(),
        '/builderHome': (context) => const BuilderHomePage(),
      },
    );
  }
}
