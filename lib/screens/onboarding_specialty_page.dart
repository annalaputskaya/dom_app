import 'package:flutter/material.dart';

class OnboardingSpecialtyPage extends StatefulWidget {
  const OnboardingSpecialtyPage({Key? key}) : super(key: key);

  @override
  State<OnboardingSpecialtyPage> createState() =>
      _OnboardingSpecialtyPageState();
}

class _OnboardingSpecialtyPageState
    extends State<OnboardingSpecialtyPage> {
  final List<String> specialties = [
    'Проектирование и подготовка работ',
    'Сметно-проектная документация',
    'Отделочные работы',
    'Фасадные работы',
    'Кровельные работы',
    'Высотные работы',
    'Монолитные работы',
    'Монтажные работы',
    'Электромонтажные работы',
    'Инженерные сети',
    'Бытовые работы',
    'Садоводческие работы',
    'Сельскохозяйственные работы',
    'Благоустройство земельного участка',
  ];

  final Set<String> selectedSpecialties = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Stack(
        children: [

          /// ОСНОВНОЙ КОНТЕНТ
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 40),

                  /// Заголовок
                  const Center(
                    child: Text(
                      'Давайте определим вашу специальность',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Список специализаций
                  Expanded(
                    child: ListView.builder(
                      itemCount: specialties.length,
                      itemBuilder: (context, index) {
                        final item = specialties[index];
                        final isSelected =
                            selectedSpecialties.contains(item);

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedSpecialties.remove(item);
                                } else {
                                  selectedSpecialties.add(item);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4F6EF7)
                                    : Colors.grey.shade300,
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Кнопка продолжить
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: selectedSpecialties.isEmpty
                          ? null
                          : () {
                              // переход дальше
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedSpecialties.isEmpty
                            ? Colors.grey.shade400
                            : const Color(0xFF1E2A47),
                        disabledBackgroundColor:
                            Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Продолжить',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: selectedSpecialties.isEmpty
                              ? Colors.grey.shade700
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// СТРЕЛКА НАЗАД (как на прошлой странице)
          Positioned(
            top: 20,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}