import 'package:app/providers/login_provider.dart';
import 'package:app/providers/register_provider.dart';
import 'package:app/views/login/login_screen.dart';
import 'package:app/views/login/register_screen.dart';
import 'package:provider/provider.dart';

class Providers {
  static final providersList = [
    ChangeNotifierProvider(create: (_) => LoginProvider()),
    ChangeNotifierProvider(create: (_) => RegisterProvider())
  ];
}