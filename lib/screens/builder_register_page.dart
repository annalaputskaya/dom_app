import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'success_bld_page.dart';

class BuilderRegisterPage extends StatefulWidget {
  const BuilderRegisterPage({super.key});

  @override
  State<BuilderRegisterPage> createState() => _BuilderRegisterPageState();
}

class _BuilderRegisterPageState extends State<BuilderRegisterPage> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);
  
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  String? selectedSpecialty;
  String? selectedExperience;
  LatLng? selectedLocation;
  bool isLoading = false;
  bool isAgreedToTerms = false; // ✅ Галочка согласия

  final List<String> specialties = [
    "Архитектор", "Инженер-строитель", "Инженер-сметчик", "Прораб",
    "Каменщик", "Бетонщик", "Плотник", "Арматурщик", "Отделочник",
    "Сварщик", "Кровельщик", "Маляр", "Монтажник", "Плиточник",
    "Сантехник", "Печник", "Промышленный альпинист"
  ];

  final List<String> experiences = ["Без опыта", "1-3 года", "3-6 лет", "6+ лет"];

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// 🔥 РЕГИСТРАЦИЯ
  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedLocation == null) {
      _showSnackBar("Пожалуйста, укажите место работы на карте");
      return;
    }
    
    if (!isAgreedToTerms) {
      _showSnackBar("Необходимо согласие на обработку персональных данных");
      return;
    }

    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Ошибка создания пользователя");

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': '${nameController.text.trim()} ${lastNameController.text.trim()}',
        'firstName': nameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'profession': selectedSpecialty ?? "Не указано",
        'experience': selectedExperience ?? "Не указан",
        'role': 'builder',
        'location': GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessBldPage()),
      );
    } catch (e) {
      _showSnackBar("Ошибка: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// 🗺 Вызов карты для выбора места
  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerPage()),
    );
    if (result != null) {
      setState(() => selectedLocation = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: primaryDark,
        elevation: 0,
        title: const Text("Регистрация мастера", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: accentOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(nameController, "Имя", Icons.person),
                    const SizedBox(height: 16),
                    _buildField(lastNameController, "Фамилия", Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildField(emailController, "Email", Icons.email, isEmail: true),
                    const SizedBox(height: 16),
                    _buildField(passwordController, "Пароль", Icons.lock, isPassword: true),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: selectedSpecialty,
                      decoration: _inputDecoration("Специализация", Icons.handyman),
                      items: specialties.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => selectedSpecialty = val),
                      validator: (v) => v == null ? "Выберите специализацию" : null,
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: selectedExperience,
                      decoration: _inputDecoration("Опыт работы", Icons.timeline),
                      items: experiences.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => selectedExperience = val),
                      validator: (v) => v == null ? "Выберите опыт" : null,
                    ),
                    const SizedBox(height: 16),

                    /// 📍 Кнопка выбора места
                    InkWell(
                      onTap: _pickLocation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: selectedLocation == null ? Colors.transparent : accentOrange, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: selectedLocation == null ? primaryDark : accentOrange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedLocation == null 
                                    ? "Укажите место, где удобно работать" 
                                    : "Местоположение выбрано ✅",
                                style: TextStyle(
                                  color: selectedLocation == null ? Colors.black54 : accentOrange,
                                  fontWeight: selectedLocation == null ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    /// ✅ ГАЛОЧКА СОГЛАСИЯ (простая, без recognizer)
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
                        onPressed: registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          "Зарегистрироваться",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryDark),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: _inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Обязательно";
        if (isPassword && value.length < 6) return "Минимум 6 символов";
        if (isEmail && !value.contains("@")) return "Некорректный email";
        return null;
      },
    );
  }
}

/// 🗾 Страница выбора точки на карте
class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng _pickedLocation = const LatLng(53.9006, 27.5590); // Центр (Минск)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Выберите точку"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 30),
            onPressed: () => Navigator.pop(context, _pickedLocation),
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _pickedLocation, zoom: 12),
        onTap: (pos) => setState(() => _pickedLocation = pos),
        markers: {
          Marker(markerId: const MarkerId("pick"), position: _pickedLocation),
        },
      ),
    );
  }
}