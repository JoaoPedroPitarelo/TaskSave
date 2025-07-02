import 'package:app/core/themes/dark/app_theme_data_dark.dart';
import 'package:app/core/themes/light/app_theme_data_light.dart';
import 'package:app/core/utils/auth_interceptor.dart';
import 'package:app/core/utils/failure_localizations_mapper.dart';

import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/providers/app_preferences_provider.dart';
import 'package:app/presentation/providers/password_rescue_provider.dart';
import 'package:app/presentation/screens/categoryForm/category_form_screen.dart';
import 'package:app/presentation/screens/categoryForm/category_form_viewmodel.dart';
import 'package:app/presentation/screens/home/home_screen.dart';
import 'package:app/presentation/screens/home/home_viewmodel.dart';
import 'package:app/presentation/screens/password_change/password_change_screen.dart';
import 'package:app/presentation/screens/password_change/password_change_viewmodel.dart';
import 'package:app/presentation/screens/wrapper.dart';

import 'package:app/repositories/auth_repository.dart';
import 'package:app/repositories/category_repository.dart';
import 'package:app/services/auth/auth_service.dart';

import 'package:app/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  await authService.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AppPreferencesProvider(),
      ),
      Provider<AuthService>(
          create: (context) => authService,
          lazy: false
      ),
      ChangeNotifierProvider(
        create: (context) {
          final authService = context.read<AuthService>();
          return AuthProvider(authService);
        }
      ),
      Provider<Dio>(create: (context) => Dio()),
      Provider<AuthRepository>(
        create: (context) => AuthRepository(
          Provider.of<Dio>(context, listen: false),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => PasswordRescueProvider(),
      ),
      ChangeNotifierProvider(
        create: (ctx) => HomeViewmodel(
          CategoryRepository(Provider.of<Dio>(ctx, listen: false)),
          (failure) => mapFailureToLocalizationMessage(ctx, failure)
        ),
        child: HomeScreen(),
      ),
    ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    initiliazeInterceptorAndListeners();
  }

  @override
  void dispose() {
    Provider.of<AuthProvider>(context, listen: false).removeListener(_onAuthChanged);
    Provider.of<PasswordRescueProvider>(context, listen: false).removeListener(_checkAndNavigateBasedOnDeepLink);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndNavigateBasedOnDeepLink();
  }

  void initiliazeInterceptorAndListeners() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      final dio = Provider.of<Dio>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final authApiDioService = Provider.of<AuthRepository>(context, listen: false);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final passwordRescueProvider = Provider.of<PasswordRescueProvider>(context, listen: false);

      dio.options.baseUrl = 'http://10.0.0.4:8080';
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      dio.interceptors.add(AuthInterceptor(
        authApiDioService,
        authService,
        authProvider,
        dio,
      ));
    
      authProvider.addListener(_onAuthChanged);
      passwordRescueProvider.addListener(_checkAndNavigateBasedOnDeepLink);
    });
  }

  void _checkAndNavigateBasedOnDeepLink() {
    final passwordRescueProvider = context.read<PasswordRescueProvider>();

    final String? token = passwordRescueProvider.pendingRescueToken;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (token != null) {
        navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (ctx) => PasswordResetViewmodel(
                Provider.of<AuthRepository>(ctx, listen: false),
                (failure) => mapFailureToLocalizationMessage(ctx, failure)
              ),
              child: PasswordResetScreen(
                rescueToken: token
              ),
            )
        )
        ).then( (_) {
          passwordRescueProvider.clearRescueToken();
        }
        );
      }
    });
  }

  void _onAuthChanged() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      navigatorKey.currentState?.popUntil((screen) => screen.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencesProvider = context.watch<AppPreferencesProvider>();

    preferencesProvider.toggleTheme(isDark: false);

    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppThemeDataLight.lightTheme,
      darkTheme: AppThemeDataDark.darkTheme,
      themeMode: preferencesProvider.themeMode,
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        // TODO ao final do projeto adicionar as demais linguagens
        //Locale('en'),
        Locale('pt', 'BR')
      ],
      locale: preferencesProvider.appLanguage,
      home: Wrapper(),
    );
  }
}
