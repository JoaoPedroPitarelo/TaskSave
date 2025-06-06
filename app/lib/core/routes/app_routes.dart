import 'package:app/core/utils/failure_localizations_mapper.dart';
import 'package:app/presentation/views/login/login_viewmodel.dart';
import 'package:app/presentation/views/register/register_viewmodel.dart';
import 'package:app/presentation/views/home_screen.dart';
import 'package:app/presentation/views/register/confirm_email_screen.dart';
import 'package:app/presentation/views/login/login_screen.dart';
import 'package:app/presentation/views/register/register_screen.dart';
import 'package:app/presentation/views/welcome_splashscreen/screen1.dart';
import 'package:app/presentation/views/welcome_splashscreen/screen2.dart';
import 'package:app/presentation/views/welcome_splashscreen/screen3.dart';
import 'package:app/presentation/views/welcome_splashscreen/screen4.dart';
import 'package:app/presentation/views/welcome_splashscreen/screen5_final.dart';
import 'package:app/services/auth_service.dart';
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
      create: (context) => RegisterViewModel(AuthService(), (failure) => mapFailureToLocalizationMessage(context, failure)),
      child: RegisterScreen()
    ),
    "/login": (_) => ChangeNotifierProvider(
      create: (context) => LoginViewModel(AuthService(), (failure) => mapFailureToLocalizationMessage(context, failure)),
      child: LoginScreen(),
    ),
    "/confirmEmail": (_) => ConfirmEmailScreen(),
    "/home": (_) => HomeScreen()
  };
}