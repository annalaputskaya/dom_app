import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  static const Color primaryDark =
      Color(0xFF1A2238);

  static const Color accentOrange =
      Color(0xFFF08A08);

  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _loginController =
      TextEditingController();

  final _currentPasswordController =
      TextEditingController();

  final _newPasswordController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _canChangePassword = false;

  File? _avatarFile;
  File? _resumeFile;

  String? _currentAvatarUrl;
  String? _currentResumeName;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  ////////////////////////////////////////////////////////////////////////////
  /// LOAD PROFILE
  ////////////////////////////////////////////////////////////////////////////

  Future<void> _loadCurrentProfile() async {
    try {
      final stream =
          ProfileService.getProfile();

      final snapshot = await stream.first;

      final data =
          snapshot.data()
              as Map<String, dynamic>?;

      final currentUser =
          FirebaseAuth.instance.currentUser;

      if (data != null) {
        setState(() {
          _nameController.text =
              data['name'] ?? '';

          // ✅ ПОЛНЫЙ EMAIL
          _loginController.text =
              currentUser?.email ??
                  data['login'] ??
                  '';

          _currentAvatarUrl =
              data['avatarUrl'];

          _currentResumeName =
              data['resumeName'];

          _isLoading = false;
        });
      } else {
        setState(() {
          _loginController.text =
              currentUser?.email ?? '';

          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        "Ошибка загрузки данных",
        isError: true,
      );
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// VERIFY PASSWORD
  ////////////////////////////////////////////////////////////////////////////

  Future<void> _verifyOldPassword() async {
    if (_currentPasswordController
        .text
        .isEmpty) {
      return;
    }

    final isValid =
        await ProfileService.verifyPassword(
      _currentPasswordController.text,
    );

    setState(() {
      _canChangePassword = isValid;
    });

    if (!isValid) {
      _showSnackBar(
        "Неверный текущий пароль!",
        isError: true,
      );
    } else {
      _showSnackBar(
        "Пароль подтвержден",
      );
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// PICK AVATAR
  ////////////////////////////////////////////////////////////////////////////

  Future<void> _pickAvatar() async {
    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null &&
        result.files.single.path != null) {
      setState(() {
        _avatarFile = File(
          result.files.single.path!,
        );
      });
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// PICK RESUME
  ////////////////////////////////////////////////////////////////////////////

  Future<void> _pickResume() async {
    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null &&
        result.files.single.path != null) {
      setState(() {
        _resumeFile = File(
          result.files.single.path!,
        );
      });
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// SAVE
  ////////////////////////////////////////////////////////////////////////////

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ProfileService.updateProfile(
        name: _nameController.text.trim(),
        login: _loginController.text.trim(),
        avatar: _avatarFile,
        resume: _resumeFile,
      );

      if (_canChangePassword &&
          _newPasswordController
              .text
              .isNotEmpty) {
        await ProfileService.changePassword(
          _newPasswordController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Профиль успешно обновлен!",
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar(
        "Ошибка сохранения данных",
        isError: true,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// SNACKBAR
  ////////////////////////////////////////////////////////////////////////////

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? Colors.red
                : Colors.green,
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    ImageProvider? avatarProvider;

    if (_avatarFile != null) {
      avatarProvider =
          FileImage(_avatarFile!);
    } else if (_currentAvatarUrl !=
            null &&
        _currentAvatarUrl!.isNotEmpty) {
      try {
        avatarProvider = MemoryImage(
          base64Decode(
            _currentAvatarUrl!,
          ),
        );
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Редактировать профиль",

          style: TextStyle(
            color: primaryDark,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            children: [

              ////////////////////////////////////////////////////////////
              /// AVATAR
              ////////////////////////////////////////////////////////////

              Stack(
                children: [
                  CircleAvatar(
                    radius: 55,

                    backgroundColor:
                        accentOrange
                            .withOpacity(
                      0.15,
                    ),

                    backgroundImage:
                        avatarProvider,

                    child:
                        avatarProvider ==
                                null
                            ? const Icon(
                                Icons.person,
                                size: 55,
                                color:
                                    accentOrange,
                              )
                            : null,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,

                    child:
                        GestureDetector(
                      onTap:
                          _pickAvatar,

                      child: Container(
                        padding:
                            const EdgeInsets
                                .all(8),

                        decoration:
                            const BoxDecoration(
                          color:
                              accentOrange,

                          shape:
                              BoxShape
                                  .circle,
                        ),

                        child:
                            const Icon(
                          Icons.edit,
                          color:
                              Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              ////////////////////////////////////////////////////////////
              /// NAME
              ////////////////////////////////////////////////////////////

              _buildField(
                controller:
                    _nameController,

                label: "Имя",

                icon:
                    Icons.person_outline,
              ),

              const SizedBox(
                height: 18,
              ),

              ////////////////////////////////////////////////////////////
              /// EMAIL
              ////////////////////////////////////////////////////////////

              _buildField(
                controller:
                    _loginController,

                label: "Email",

                icon:
                    Icons.email_outlined,
              ),

              const SizedBox(
                height: 30,
              ),

              ////////////////////////////////////////////////////////////
              /// PASSWORD TITLE
              ////////////////////////////////////////////////////////////

              const Align(
                alignment:
                    Alignment.centerLeft,

                child: Text(
                  "Смена пароля",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        primaryDark,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              ////////////////////////////////////////////////////////////
              /// CURRENT PASSWORD
              ////////////////////////////////////////////////////////////

              TextFormField(
                controller:
                    _currentPasswordController,

                obscureText: true,

                decoration:
                    InputDecoration(
                  labelText:
                      "Текущий пароль",

                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                    color:
                        accentOrange,
                  ),

                  suffixIcon:
                      IconButton(
                    icon: Icon(
                      _canChangePassword
                          ? Icons
                              .check_circle
                          : Icons
                              .check,

                      color:
                          _canChangePassword
                              ? Colors
                                  .green
                              : Colors
                                  .grey,
                    ),

                    onPressed:
                        _verifyOldPassword,
                  ),

                  filled: true,
                  fillColor:
                      Colors.white,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              ////////////////////////////////////////////////////////////
              /// NEW PASSWORD
              ////////////////////////////////////////////////////////////

              TextFormField(
                controller:
                    _newPasswordController,

                obscureText: true,

                enabled:
                    _canChangePassword,

                decoration:
                    InputDecoration(
                  labelText:
                      "Новый пароль",

                  prefixIcon:
                      const Icon(
                    Icons
                        .lock_reset_outlined,

                    color:
                        accentOrange,
                  ),

                  filled: true,
                  fillColor:
                      Colors.white,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),

                validator: (v) {
                  if (_canChangePassword &&
                      (v == null ||
                          v.isEmpty)) {
                    return "Введите новый пароль";
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 30,
              ),

              ////////////////////////////////////////////////////////////
              /// RESUME
              ////////////////////////////////////////////////////////////

              _buildResumeCard(),

              const SizedBox(
                height: 40,
              ),

              ////////////////////////////////////////////////////////////
              /// SAVE BUTTON
              ////////////////////////////////////////////////////////////

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        primaryDark,

                    foregroundColor:
                        Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),
                  ),

                  onPressed:
                      _isSaving
                          ? null
                          : _save,

                  child:
                      _isSaving
                          ? const CircularProgressIndicator(
                              color:
                                  Colors.white,

                              strokeWidth:
                                  2,
                            )
                          : const Text(
                              "Сохранить изменения",

                              style:
                                  TextStyle(
                                fontSize:
                                    16,

                                fontWeight:
                                    FontWeight.bold,
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

  ////////////////////////////////////////////////////////////////////////////
  /// FIELD
  ////////////////////////////////////////////////////////////////////////////

  Widget _buildField({
    required TextEditingController
        controller,

    required String label,

    required IconData icon,

    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(
          icon,
          color: accentOrange,
        ),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),

          borderSide:
              BorderSide.none,
        ),
      ),

      validator: (v) {
        if (v == null || v.isEmpty) {
          return "Поле не может быть пустым";
        }

        return null;
      },
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  /// RESUME CARD
  ////////////////////////////////////////////////////////////////////////////

  Widget _buildResumeCard() {
    String resumeStatus =
        "Файл не выбран";

    if (_resumeFile != null) {
      resumeStatus =
          "Выбран: ${_resumeFile!.path.split('/').last}";
    } else if (_currentResumeName !=
        null) {
      resumeStatus =
          "Текущий: $_currentResumeName";
    }

    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: Row(
        children: [

          Container(
            padding:
                const EdgeInsets.all(
              12,
            ),

            decoration: BoxDecoration(
              color: accentOrange
                  .withOpacity(0.12),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: const Icon(
              Icons
                  .description_outlined,

              color: accentOrange,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                const Text(
                  "Резюме",

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,

                    color:
                        primaryDark,

                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  resumeStatus,

                  style: TextStyle(
                    color: Colors
                        .grey
                        .shade600,

                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          OutlinedButton(
            onPressed: _pickResume,

            style:
                OutlinedButton
                    .styleFrom(
              foregroundColor:
                  accentOrange,

              side:
                  const BorderSide(
                color:
                    accentOrange,
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),
            ),

            child: const Text(
              "Выбрать",
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();

    _loginController.dispose();

    _currentPasswordController
        .dispose();

    _newPasswordController
        .dispose();

    super.dispose();
  }
}