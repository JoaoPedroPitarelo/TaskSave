import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/presentation/screens/home/home_screen.dart';
import 'package:task_save/presentation/screens/welcome/first_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_save/presentation/global_providers/auth_provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appColor = AppGlobalColors.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: authProvider.isLoading ? 0.0 : 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        if (value < 1.0) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: Image.asset(appColor.taskSaveLogo!),
                  ),
                  CircularProgressIndicator(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                    strokeWidth: 4,
                    strokeAlign: 5,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }
        return child!;
      },
      child: authProvider.isAuthenticated
        ? const HomeScreen()
        : const FirstWelcomeScreen(),
    );
  }
}
