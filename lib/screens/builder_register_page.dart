import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'success_bld_page.dart';
import 'yandex_map_picker.dart';

class BuilderRegisterPage extends StatefulWidget {
  const BuilderRegisterPage({super.key});

  @override
  State<BuilderRegisterPage> createState() =>
      _BuilderRegisterPageState();
}

class _BuilderRegisterPageState
    extends State<BuilderRegisterPage> {

  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedSpecialty;
  String? selectedExperience;

  // Используем Point
  Point? selectedLocation;

  bool isLoading = false;
  bool isAgreedToTerms = false;

  final List<String> specialties = [

    "Архитектор",
    "Инженер-строитель",
    "Инженер-сметчик",
    "Прораб",
    "Каменщик",
    "Бетонщик",
    "Плотник",
    "Арматурщик",
    "Отделочник",
    "Сварщик",
    "Кровельщик",
    "Маляр",
    "Монтажник",
    "Плиточник",
    "Сантехник",
    "Печник",
    "Промышленный альпинист"
  ];

  final List<String> experiences = [

    "Без опыта",
    "1-3 года",
    "3-6 лет",
    "6+ лет"
  ];

  @override
  void dispose() {

    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // Snackbar
  void _showSnackBar(String text) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // Открытие карты
  Future<void> _pickLocation() async {

    final Point? result =
        await Navigator.push(

      context,

      MaterialPageRoute(
        builder: (_) =>
            const YandexMapPickerPage(),
      ),
    );

    if (result != null) {

      setState(() {

        selectedLocation = result;
      });
    }
  }

  // Регистрация
  Future<void> registerUser() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedLocation == null) {

      _showSnackBar(
        "Укажите место работы на карте",
      );

      return;
    }

    if (!isAgreedToTerms) {

      _showSnackBar(
        "Подтвердите согласие",
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final userCredential = await FirebaseAuth
          .instance
          .createUserWithEmailAndPassword(

        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          "Ошибка регистрации",
        );
      }

      // Сохранение в Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({

        'uid': user.uid,

        'firstName':
            nameController.text.trim(),

        'lastName':
            lastNameController.text.trim(),

        'name':
            '${nameController.text.trim()} ${lastNameController.text.trim()}',

        'email':
            emailController.text.trim(),

        'profession':
            selectedSpecialty,

        'experience':
            selectedExperience,

        'role': 'builder',

        // Локация
        'location': GeoPoint(
          selectedLocation!.latitude,
          selectedLocation!.longitude,
        ),

        'createdAt':
            FieldValue.serverTimestamp(),

      });

      if (!mounted) return;

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder: (_) =>
              const SuccessBldPage(),
        ),
      );

    } catch (e) {

      _showSnackBar(
        'Ошибка: $e',
      );

    } finally {

      if (mounted) {

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF4F7FA),

      appBar: AppBar(

        backgroundColor: primaryDark,

        title: const Text(
          'Регистрация мастера',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(24),

              child: Form(

                key: _formKey,

                child: Column(

                  children: [

                    _buildField(
                      nameController,
                      'Имя',
                      Icons.person,
                    ),

                    const SizedBox(height: 16),

                    _buildField(
                      lastNameController,
                      'Фамилия',
                      Icons.person_outline,
                    ),

                    const SizedBox(height: 16),

                    _buildField(
                      emailController,
                      'Email',
                      Icons.email,
                      isEmail: true,
                    ),

                    const SizedBox(height: 16),

                    _buildField(
                      passwordController,
                      'Пароль',
                      Icons.lock,
                      isPassword: true,
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(

                      value:
                          selectedSpecialty,

                      decoration:
                          _inputDecoration(
                        'Специализация',
                        Icons.handyman,
                      ),

                      items: specialties
                          .map(
                            (e) =>
                                DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),

                      onChanged: (value) {

                        setState(() {

                          selectedSpecialty =
                              value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(

                      value:
                          selectedExperience,

                      decoration:
                          _inputDecoration(
                        'Опыт',
                        Icons.timeline,
                      ),

                      items: experiences
                          .map(
                            (e) =>
                                DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),

                      onChanged: (value) {

                        setState(() {

                          selectedExperience =
                              value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    InkWell(

                      onTap: _pickLocation,

                      child: Container(

                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(16),

                        decoration: BoxDecoration(

                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),

                          border: Border.all(
                            color: accentOrange,
                            width: 2,
                          ),
                        ),

                        child: Row(

                          children: [

                            Icon(
                              Icons.location_on,
                              color: accentOrange,
                            ),

                            const SizedBox(width: 12),

                            Expanded(

                              child: Text(

                                selectedLocation == null

                                    ? 'Выбрать место работы'

                                    : 'Выбрано: ${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    CheckboxListTile(

                      value: isAgreedToTerms,

                      onChanged: (value) {

                        setState(() {

                          isAgreedToTerms =
                              value ?? false;
                        });
                      },

                      title: const Text(
                        'Согласен на обработку данных',
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(

                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(

                        onPressed:
                            registerUser,

                        style:
                            ElevatedButton.styleFrom(

                          backgroundColor:
                              accentOrange,
                        ),

                        child: const Text(
                          'Зарегистрироваться',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Поля
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

      keyboardType: isEmail
          ? TextInputType.emailAddress
          : TextInputType.text,

      decoration:
          _inputDecoration(label, icon),

      validator: (value) {

        if (value == null ||
            value.trim().isEmpty) {

          return 'Заполните поле';
        }

        return null;
      },
    );
  }

  // Дизайн полей
  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {

    return InputDecoration(

      labelText: label,

      prefixIcon: Icon(icon),

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(14),

        borderSide: BorderSide.none,
      ),
    );
  }
}