import 'package:app/presentation/screens/home/home_screen.dart';
import 'package:app/presentation/screens/welcome/first_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/presentation/global_providers/auth_provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    print('Wrapper DEBUG: rebuild com isAuthenticated: ${authProvider.isAuthenticated}');

    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          // TODO criar um widget com o logo do TaskSave e o CircularProgressIndicator assim como nos protótipos
          child: CircularProgressIndicator(),
        ),
      );
    } else if (authProvider.isAuthenticated) {
      return HomeScreen();
    } else {
      return const FirstWelcomeScreen();
    }
  }
}
