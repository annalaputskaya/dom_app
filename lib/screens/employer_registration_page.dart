import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'success_emp_page.dart';

class EmployerRegistrationPage extends StatefulWidget {
  const EmployerRegistrationPage({super.key});

  @override
  State<EmployerRegistrationPage> createState() => _EmployerRegistrationPageState();
}

class _EmployerRegistrationPageState extends State<EmployerRegistrationPage> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final organizationController = TextEditingController();

  String? selectedType;
  final List<String> companyTypes = [
    "Строительная компания",
    "Частный заказчик",
    "Подрядчик",
    "Другое"
  ];

  bool isLoading = false;
  bool isAgreedToTerms = false; // ✅ Галочка согласия

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    organizationController.dispose();
    super.dispose();
  }

  Future<void> _registerAndSaveData() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!isAgreedToTerms) {
      _showSnackBar("Необходимо согласие на обработку персональных данных");
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          )
          .timeout(const Duration(seconds: 10));

      final uid = userCredential.user!.uid;

      if (!mounted) return;

      // Переход сразу (без зависания)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SuccessEmpPage()),
      );

      // Сохранение в фоне
      _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': emailController.text.trim(),
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'organization': organizationController.text.trim(),
        'type': selectedType ?? "Не указан",
        'role': 'employer',
        'createdAt': FieldValue.serverTimestamp(),
      }).catchError((e) {
        debugPrint("Firestore error: $e");
      });

    } on FirebaseAuthException catch (e) {
      String message = "Ошибка регистрации";

      if (e.code == 'email-already-in-use') {
        message = "Этот email уже занят";
      } else if (e.code == 'weak-password') {
        message = "Слишком слабый пароль";
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Регистрация работодателя",
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Личные данные",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(firstNameController, "Имя", Icons.person_outline),
                    const SizedBox(height: 12),

                    _buildTextField(lastNameController, "Фамилия", Icons.people_outline),

                    const SizedBox(height: 24),

                    const Text(
                      "Организация",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      organizationController,
                      "Название (если есть)",
                      Icons.business_outlined,
                      required: false,
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: "Тип деятельности",
                        prefixIcon: Icon(Icons.category_outlined, color: primaryDark),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: companyTypes
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedType = value),
                      validator: (value) =>
                          value == null ? "Выберите тип" : null,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Данные для входа",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(emailController, "Email",
                        Icons.email_outlined,
                        isEmail: true),

                    const SizedBox(height: 12),

                    _buildTextField(passwordController, "Пароль",
                        Icons.lock_outline,
                        isPassword: true),

                    const SizedBox(height: 16),

                    /// ✅ ГАЛОЧКА СОГЛАСИЯ
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isAgreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                isAgreedToTerms = value ?? false;
                              });
                            },
                            activeColor: accentOrange,
                            checkColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isAgreedToTerms = !isAgreedToTerms;
                              });
                            },
                            child: const Text(
                              "Я согласен на обработку персональных данных",
                              style: TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _registerAndSaveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Зарегистрироваться",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isEmail = false,
    bool required = true,
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return "Поле обязательно";
        }
        if (isPassword && value!.length < 6) {
          return "Минимум 6 символов";
        }
        if (isEmail && !value!.contains("@")) {
          return "Некорректный Email";
        }
        return null;
      },
    );
  }
}