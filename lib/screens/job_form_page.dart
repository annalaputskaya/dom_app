import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sjb_page.dart';

class CreateJobPage extends StatefulWidget {
  const CreateJobPage({super.key});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  // 🎨 Цвета
  final Color primaryDark = const Color(0xFF0F172A);
  final Color accentOrange = const Color(0xFFF97316);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textSecondary = const Color(0xFF64748B);
  final Color inputBg = const Color(0xFFF1F5F9);

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();

  final List<TextEditingController> _phoneControllers = [
    TextEditingController()
  ];

  bool _isNegotiable = false;
  String _priceType = "за работу";
  String _contactMethod = "Звонки и сообщения";

  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _nameController.dispose();
    _commentController.dispose();

    for (var c in _phoneControllers) {
      c.dispose();
    }

    super.dispose();
  }

  ////////////////////////////////////////////////////////////////////////////
  /// 🚀 СОЗДАНИЕ ОБЪЯВЛЕНИЯ
  ////////////////////////////////////////////////////////////////////////////

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("Пользователь не авторизован");
      }

      await FirebaseFirestore.instance.collection('jobs').add({
        // Основные данные
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'comment': _commentController.text.trim(),

        // Цена
        'price':
            _isNegotiable ? "" : _priceController.text.trim(),

        'priceType':
            _isNegotiable ? "" : _priceType,

        'isNegotiable': _isNegotiable,

        // Контакты
        'contactMethod': _contactMethod,

        'phones': _contactMethod == "Звонки и сообщения"
            ? _phoneControllers
                .map((e) => e.text.trim())
                .toList()
            : [],

        // Информация
        'location': _locationController.text.trim(),
        'name': _nameController.text.trim(),

        // 🔥 ВАЖНО
        'userId': user.uid,
        'userEmail': user.email,

        // Дата
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Объявление опубликовано"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SjbPage(),
        ),
      );
    } catch (e) {
      debugPrint("ERROR CREATE JOB: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ошибка: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// UI
  ////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Подача объявления",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: accentOrange,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    ////////////////////////////////////////////////////////////////////////////
                    /// ОСНОВНАЯ ИНФОРМАЦИЯ
                    ////////////////////////////////////////////////////////////////////////////

                    _buildSectionHeader(
                      "Основная информация",
                    ),

                    _buildCard([
                      _buildField(
                        _titleController,
                        "Название",
                        Icons.work_outline,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        _descController,
                        "Описание",
                        Icons.description_outlined,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        _commentController,
                        "Комментарий к заказу",
                        Icons.comment_outlined,
                        maxLines: 3,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    ////////////////////////////////////////////////////////////////////////////
                    /// СТОИМОСТЬ
                    ////////////////////////////////////////////////////////////////////////////

                    _buildSectionHeader("Стоимость"),

                    _buildCard([

                      SwitchListTile(
                        value: _isNegotiable,
                        activeColor: accentOrange,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Договорная цена",
                          style: TextStyle(
                            color: primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onChanged: (v) {
                          setState(() {
                            _isNegotiable = v;
                          });
                        },
                      ),

                      if (!_isNegotiable) ...[
                        const SizedBox(height: 12),

                        Row(
                          children: [

                            Expanded(
                              flex: 11,
                              child: TextFormField(
                                controller:
                                    _priceController,
                                keyboardType:
                                    TextInputType.number,
                                decoration: _input(
                                  "Цена",
                                  Icons.payments_outlined,
                                ),
                                validator: (v) {
                                  if (!_isNegotiable &&
                                      (v == null ||
                                          v.isEmpty)) {
                                    return "Введите цену";
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              flex: 9,
                              child:
                                  DropdownButtonFormField<
                                      String>(
                                value: _priceType,
                                isExpanded: true,
                                decoration: _input(
                                  "",
                                  null,
                                  hidePadding: true,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "за работу",
                                    child:
                                        Text("за работу"),
                                  ),
                                  DropdownMenuItem(
                                    value: "в час",
                                    child: Text("в час"),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    _priceType = v!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ]),

                    const SizedBox(height: 24),

                    ////////////////////////////////////////////////////////////////////////////
                    /// СВЯЗЬ
                    ////////////////////////////////////////////////////////////////////////////

                    _buildSectionHeader("Связь"),

                    _buildCard([

                      DropdownButtonFormField<String>(
                        value: _contactMethod,
                        isExpanded: true,
                        decoration: _input(
                          "Способ связи",
                          Icons.contact_phone_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Звонки и сообщения",
                            child: Text(
                              "Звонки и сообщения",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Только сообщения",
                            child:
                                Text("Только сообщения"),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _contactMethod = v!;
                          });
                        },
                      ),

                      if (_contactMethod ==
                          "Звонки и сообщения") ...[
                        const SizedBox(height: 16),

                        ..._phoneControllers
                            .asMap()
                            .entries
                            .map((entry) {

                          int idx = entry.key;
                          var c = entry.value;

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: TextFormField(
                              controller: c,
                              keyboardType:
                                  TextInputType.phone,
                              decoration: _input(
                                "Телефон ${idx + 1}",
                                Icons.phone_outlined,

                                suffix:
                                    _phoneControllers
                                                .length >
                                            1
                                        ? IconButton(
                                            icon:
                                                const Icon(
                                              Icons
                                                  .remove_circle_outline,
                                              color: Colors
                                                  .redAccent,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _phoneControllers
                                                    .removeAt(
                                                        idx);
                                              });
                                            },
                                          )
                                        : null,
                              ),

                              validator: (v) {
                                if (_contactMethod ==
                                    "Звонки и сообщения") {
                                  if (v == null ||
                                      v.isEmpty) {
                                    return "Введите телефон";
                                  }
                                }
                                return null;
                              },
                            ),
                          );
                        }),

                        Align(
                          alignment:
                              Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _phoneControllers.add(
                                  TextEditingController(),
                                );
                              });
                            },
                            icon: Icon(
                              Icons.add,
                              color: accentOrange,
                              size: 20,
                            ),
                            label: Text(
                              "Добавить телефон",
                              style: TextStyle(
                                color: accentOrange,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]),

                    const SizedBox(height: 24),

                    ////////////////////////////////////////////////////////////////////////////
                    /// ЛОКАЦИЯ
                    ////////////////////////////////////////////////////////////////////////////

                    _buildSectionHeader(
                      "Локация и имя",
                    ),

                    _buildCard([
                      _buildField(
                        _locationController,
                        "Локация",
                        Icons.location_on_outlined,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        _nameController,
                        "Ваше имя",
                        Icons.person_outline,
                      ),
                    ]),

                    const SizedBox(height: 32),

                    ////////////////////////////////////////////////////////////////////////////
                    /// КНОПКА
                    ////////////////////////////////////////////////////////////////////////////

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              accentOrange,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    14),
                          ),
                        ),
                        onPressed: _submitJob,
                        child: const Text(
                          "Опубликовать",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  /// HELPERS
  ////////////////////////////////////////////////////////////////////////////

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
        left: 4,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  InputDecoration _input(
    String label,
    IconData? icon, {
    bool hidePadding = false,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText:
          label.isEmpty ? null : label,

      labelStyle: TextStyle(
        color: textSecondary,
        fontSize: 14,
      ),

      prefixIcon: icon != null
          ? Icon(
              icon,
              color: textSecondary,
              size: 20,
            )
          : null,

      suffixIcon: suffix,

      filled: true,
      fillColor: inputBg,

      contentPadding: hidePadding
          ? const EdgeInsets.symmetric(
              horizontal: 12,
            )
          : const EdgeInsets.all(16),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              accentOrange.withOpacity(0.5),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController c,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: _input(label, icon),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "Заполните поле";
        }
        return null;
      },
    );
  }
}