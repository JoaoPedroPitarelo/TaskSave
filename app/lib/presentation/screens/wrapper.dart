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
    print('Wrapper DEBUG: rebuild com isAuthenticated: ${authProvider.isAuthenticated}');

    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: Image.asset(appColor.taskSaveLogo!)
              ),
              CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                strokeWidth: 4,
                strokeAlign: 5,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );
    } else if (authProvider.isAuthenticated) {
      return HomeScreen();
    } else {
      return const FirstWelcomeScreen();
    }
  }
}
