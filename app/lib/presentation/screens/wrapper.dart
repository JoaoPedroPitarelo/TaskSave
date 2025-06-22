import 'package:app/presentation/screens/home_screen.dart';
import 'package:app/presentation/screens/welcome/welcome_screen1.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    print('Wrapper DEBUG: rebuild com isAuthenticated: ${authProvider.isAuthenticated}');

    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const WelcomeScreen1();
    }
  }
}
