import 'package:app/providers/login_provider.dart';
import 'package:app/providers/register_provider.dart';
import 'package:app/views/home_screen.dart';
import 'package:app/views/login/confirm_email_screen.dart';
import 'package:app/views/login/login_screen.dart';
import 'package:app/views/login/register_screen.dart';
import 'package:app/views/welcome_splashscreen/screen1.dart';
import 'package:app/views/welcome_splashscreen/screen2.dart';
import 'package:app/views/welcome_splashscreen/screen3.dart';
import 'package:app/views/welcome_splashscreen/screen4.dart';
import 'package:app/views/welcome_splashscreen/screen5_final.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    "/welcomeScreen1": (_) => Screen1(),
    "/welcomeScreen2": (_) => Screen2(),
    "/welcomeScreen3": (_) => Screen3(),
    "/welcomeScreen4": (_) => Screen4(),
    "/finalWelcomeScreen": (_) => Screen5Final(),
    
    "/register": (_) => ChangeNotifierProvider(
      create: (_) => RegisterProvider(),
      child: RegisterScreen()
    ),
    "/login": (_) => ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: LoginScreen(),
    ),
    "/confirmEmail": (_) => ConfirmEmailScreen(),
    "/home": (_) => HomeScreen()
  };
}