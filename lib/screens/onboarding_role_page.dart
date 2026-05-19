import 'package:flutter/material.dart';
import 'onboarding_employer_page.dart';
import 'welcome_page_specialist.dart';

enum UserRole { builder, homeowner }

class OnboardingRolePage extends StatefulWidget {
  const OnboardingRolePage({Key? key}) : super(key: key);

  @override
  State<OnboardingRolePage> createState() => _OnboardingRolePageState();
}

class _OnboardingRolePageState extends State<OnboardingRolePage> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              /// Заголовок
              const Text(
                'Добро пожаловать!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Выберите свою роль, чтобы настроить параметры работы.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              /// Карточки ролей
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      title: 'Строитель',
                      icon: Icons.construction,
                      isSelected: selectedRole == UserRole.builder,
                      onTap: () {
                        setState(() {
                          selectedRole = UserRole.builder;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RoleCard(
                      title: 'Работодатель',
                      icon: Icons.home_filled,
                      isSelected: selectedRole == UserRole.homeowner,
                      onTap: () {
                        setState(() {
                          selectedRole = UserRole.homeowner;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// Кнопка Продолжить
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedRole == null
                      ? null
                      : () {
                          if (selectedRole == UserRole.builder) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const WelcomePageSpecialist(),
                              ),
                            );
                          } else if (selectedRole == UserRole.homeowner) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const OnboardingEmployerPage(),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedRole == null
                        ? Colors.grey.shade400
                        : const Color(0xFF1E2A47),
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Продолжить',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: selectedRole == null
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
    );
  }
}

/// Карточка роли
class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F6EF7) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}