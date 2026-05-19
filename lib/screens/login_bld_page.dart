import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'builder_home_page.dart';

class LoginBldPage extends StatefulWidget {
  const LoginBldPage({super.key});

  @override
  State<LoginBldPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginBldPage> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// 🔐 ВХОД С ПРОВЕРКОЙ РОЛИ
  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      /// 🔥 ЛОГИН
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Ошибка пользователя");

      /// 🔥 ПОЛУЧАЕМ ДАННЫЕ ИЗ FIRESTORE
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (data == null) throw Exception("Нет данных пользователя");

      final role = data['role'];

      /// 🔥 ЕСЛИ ЭТО НЕ СТРОИТЕЛЬ
      if (role != 'builder') {
        String name = "";

        /// пытаемся красиво собрать имя
        if (data['firstName'] != null) {
          name = data['firstName'];
        } else if (data['name'] != null) {
          name = data['name'];
        }

        /// ❗ ВЫХОДИМ ИЗ АККАУНТА
        await FirebaseAuth.instance.signOut();

        _showSnackBar("Аккаунт зарегистрирован на работодателя: $name");
        return;
      }

      /// ✅ ЕСЛИ ВСЁ ОК → ПУСКАЕМ
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BuilderHomePage(),
        ),
      );

    } on FirebaseAuthException catch (e) {
      String message = "Ошибка входа";

      if (e.code == 'user-not-found') {
        message = "Пользователь не найден";
      } else if (e.code == 'wrong-password') {
        message = "Неверный пароль";
      } else if (e.code == 'invalid-email') {
        message = "Некорректный email";
      } else if (e.code == 'network-request-failed') {
        message = "Нет интернета";
      }

      _showSnackBar(message);

    } catch (e) {
      _showSnackBar("Ошибка: $e");

    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text),
      backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      appBar: AppBar(
        backgroundColor: primaryDark,
        title: const Text(
          "Вход строителя",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    const SizedBox(height: 20),

                    /// 🔥 ИКОНКА
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryDark.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 60,
                        color: primaryDark,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// EMAIL
                    _buildField(
                      emailController,
                      "Email",
                      Icons.email,
                      isEmail: true,
                    ),

                    const SizedBox(height: 16),

                    /// ПАРОЛЬ
                    _buildField(
                      passwordController,
                      "Пароль",
                      Icons.lock,
                      isPassword: true,
                    ),

                    const SizedBox(height: 30),

                    /// КНОПКА
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Войти",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// 🔧 Поле ввода
  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType:
          isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryDark),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Поле обязательно";
        }
        if (isEmail && !value.contains("@")) {
          return "Некорректный email";
        }
        if (isPassword && value.length < 6) {
          return "Минимум 6 символов";
        }
        return null;
      },
    );
  }
}