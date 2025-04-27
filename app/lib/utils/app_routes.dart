import 'package:app/views/home_screen.dart';
import 'package:app/views/login_screen.dart';
import 'package:app/views/welcome_splashscreen/screen1.dart';
import 'package:app/views/welcome_splashscreen/screen2.dart';
import 'package:app/views/welcome_splashscreen/screen3.dart';
import 'package:app/views/welcome_splashscreen/screen4.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    "/welcomeScreen1": (_) => Screen1(),
    "/welcomeScreen2": (_) => Screen2(),
    "/welcomeScreen3": (_) => Screen3(),
    "/welcomeScreen4": (_) => Screen4(),
    "/login": (_) => LoginScreen(),
    "/home": (_) => HomeScreen()
  };
}