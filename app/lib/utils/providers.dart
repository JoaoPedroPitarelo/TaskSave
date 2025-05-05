import 'package:app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Providers {
  static final providersList = [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ];
}