import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEmployerProfilePage extends StatefulWidget {
  const EditEmployerProfilePage({super.key});

  @override
  State<EditEmployerProfilePage> createState() =>
      _EditEmployerProfilePageState();
}

class _EditEmployerProfilePageState extends State<EditEmployerProfilePage> {
  static const Color primaryDark = Color(0xFF1A2238);
  static const Color accentOrange = Color(0xFFF08A08);

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String? avatarBase64;
  bool isLoading = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  ////////////////////////////////////////////////////////////////////////////
  /// LOAD PROFILE
  ////////////////////////////////////////////////////////////////////////////

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data == null || _loaded) return;

    _firstNameController.text =
        (data['firstName'] ?? '').toString();

    _lastNameController.text =
        (data['lastName'] ?? '').toString();

    _emailController.text =
        (data['email'] ?? user.email ?? '').toString();

    avatarBase64 = data['avatarUrl'];

    _loaded = true;

    setState(() {});
  }

  ////////////////////////////////////////////////////////////////////////////
  /// PICK IMAGE
  ////////////////////////////////////////////////////////////////////////////

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    setState(() {
      avatarBase64 = base64Encode(bytes);
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  /// SAVE PROFILE
  ////////////////////////////////////////////////////////////////////////////

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final newEmail = _emailController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      /// PASSWORD CHANGE
      if (_oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);
      }

      /// EMAIL UPDATE
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      /// DISPLAY NAME (FULL NAME)
      final fullName = "$firstName $lastName".trim();
      if (fullName.isNotEmpty) {
        await user.updateDisplayName(fullName);
      }

      /// FIRESTORE UPDATE
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstName': firstName,
        'lastName': lastName,
        'email': newEmail,
        'avatarUrl': avatarBase64,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль обновлен")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarProvider;

    if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      try {
        avatarProvider = MemoryImage(base64Decode(avatarBase64!));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Редактировать профиль",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// AVATAR
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: accentOrange.withOpacity(0.15),
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? const Icon(
                          Icons.person,
                          size: 55,
                          color: accentOrange,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: accentOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// FIRST NAME
            _buildField(
              controller: _firstNameController,
              label: "Имя",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 18),

            /// LAST NAME
            _buildField(
              controller: _lastNameController,
              label: "Фамилия",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 18),

            /// EMAIL
            _buildField(
              controller: _emailController,
              label: "Email",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Смена пароля",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
            ),

            const SizedBox(height: 18),

            _buildField(
              controller: _oldPasswordController,
              label: "Старый пароль",
              icon: Icons.lock_outline,
              obscure: true,
            ),

            const SizedBox(height: 18),

            _buildField(
              controller: _newPasswordController,
              label: "Новый пароль",
              icon: Icons.lock_reset_outlined,
              obscure: true,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: isLoading ? null : _saveProfile,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        "Сохранить изменения",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  /// FIELD
  ////////////////////////////////////////////////////////////////////////////

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: accentOrange),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}