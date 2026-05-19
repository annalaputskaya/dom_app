import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'employer_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      /// 🔥 1. ЛОГИН
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Ошибка пользователя");

      /// 🔥 2. ПОЛУЧАЕМ ДАННЫЕ ИЗ FIRESTORE
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data == null) throw Exception("Нет данных пользователя");

      final role = data['role'];

      /// ❗ ЕСЛИ ЭТО НЕ РАБОТОДАТЕЛЬ
      if (role != 'employer') {
        String name = "";

        if (data['name'] != null) {
          name = data['name'];
        } else if (data['firstName'] != null) {
          name = data['firstName'];
        }

        /// 🔴 ВЫХОДИМ
        await FirebaseAuth.instance.signOut();

        _showSnackBar("Аккаунт зарегистрирован на строителя: $name");
        return;
      }

      /// ✅ ЕСЛИ ВСЁ ОК → ПУСКАЕМ
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EmployerHomePage(),
        ),
      );

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Ошибка входа";

      if (e.code == 'user-not-found') {
        errorMessage = "Пользователь с таким email не найден";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Неверный пароль";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Некорректный формат почты";
      } else if (e.code == 'user-disabled') {
        errorMessage = "Аккаунт заблокирован";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "Нет интернета";
      }

      _showSnackBar(errorMessage);

    } catch (e) {
      _showSnackBar("Ошибка: $e");

    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.business_center, size: 80, color: primaryDark),
                const SizedBox(height: 24),
                const Text(
                  "Вход для работодателя",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                _buildInput(emailController, "Email", Icons.email_outlined, false),
                const SizedBox(height: 16),

                _buildInput(passwordController, "Пароль", Icons.lock_outline, true),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Войти",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Вернуться назад",
                      style: TextStyle(color: primaryDark)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
      TextEditingController controller, String label, IconData icon, bool isPass) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryDark),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      validator: (v) => v == null || v.isEmpty ? "Заполните поле" : null,
    );
  }
}