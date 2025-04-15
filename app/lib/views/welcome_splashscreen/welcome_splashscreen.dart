import 'package:app/views/welcome_splashscreen/screen1.dart';
import 'package:app/views/welcome_splashscreen/screen2.dart';
import 'package:app/views/welcome_splashscreen/screen3.dart';
import 'package:flutter/material.dart';

class WelcomeSplashscreen extends StatefulWidget {
  @override
  State<WelcomeSplashscreen> createState() => _WelcomeSplashscreenState();
}

class _WelcomeSplashscreenState extends State<WelcomeSplashscreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    Screen1(),
    Screen2(),
    Screen3()
    ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
    // } else {
    //   // Vai para o login
    //   Navigator.pushReplacementNamed(context, "/login");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: _pages,
      ),
    );
  }
}
