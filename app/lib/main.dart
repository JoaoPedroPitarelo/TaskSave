import 'package:task_save/core/themes/dark/app_theme_data_dark.dart';
import 'package:task_save/core/themes/light/app_theme_data_light.dart';
import 'package:task_save/core/utils/auth_interceptor.dart';
import 'package:task_save/core/utils/map_failure_to_failure_key.dart';
import 'package:task_save/presentation/global_providers/auth_provider.dart';
import 'package:task_save/presentation/global_providers/app_preferences_provider.dart';
import 'package:task_save/presentation/global_providers/password_rescue_provider.dart';
import 'package:task_save/presentation/screens/category_form/category_form_viewmodel.dart';
import 'package:task_save/presentation/screens/home/category_viewmodel.dart';
import 'package:task_save/presentation/screens/home/home_viewmodel.dart';
import 'package:task_save/presentation/screens/home/task_viewmodel.dart';
import 'package:task_save/presentation/screens/login/login_viewmodel.dart';
import 'package:task_save/presentation/screens/password_change/password_change_screen.dart';
import 'package:task_save/presentation/screens/password_change/password_change_viewmodel.dart';
import 'package:task_save/presentation/screens/password_rescue/password_rescue_viewmodel.dart';
import 'package:task_save/presentation/screens/register/register_viewmodel.dart';
import 'package:task_save/presentation/screens/task_details/task_details_viewmodel.dart';
import 'package:task_save/presentation/screens/task_form/task_form_viewmodel.dart';
import 'package:task_save/presentation/screens/wrapper.dart';
import 'package:task_save/repositories/api/attachment_repository.dart';
import 'package:task_save/repositories/api/auth_repository.dart';
import 'package:task_save/repositories/api/category_repository.dart';
import 'package:task_save/repositories/api/subtask_repository.dart';
import 'package:task_save/repositories/api/task_repository.dart';
import 'package:task_save/repositories/local/local_attachment_repository.dart';
import 'package:task_save/services/auth/auth_service.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/services/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:task_save/core/enums/task_type_enum.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/presentation/screens/task_details/task_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String _pendingNotificationPayloadKey = 'pending_notification_payload';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  print('[BACKGROUND NOTIFICATION] Handler called!');
  if (notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty) {
    print('[BACKGROUND NOTIFICATION] Payload received: ${notificationResponse.payload}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingNotificationPayloadKey, notificationResponse.payload!);
    print('[BACKGROUND NOTIFICATION] Payload saved to SharedPreferences.');
  } else {
    print('[BACKGROUND NOTIFICATION] Received notification with no payload.');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  await authService.init();

  await initializeDateFormatting();

  final notificationService = NotificationService();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AppPreferencesProvider(),
      ),
      Provider<NotificationService>(
        create: (context) => notificationService
      ),
      Provider<AuthService>(
          create: (context) => authService,
          lazy: false
      ),
      Provider<LocalAttachmentRepository>(
        create: (context) => LocalAttachmentRepository(),
      ),
      ChangeNotifierProvider(
        create: (context) {
          final authService = context.read<AuthService>();
          return AuthProvider(authService);
        }
      ),
      Provider<Dio>(
        create: (context) => Dio()
      ),
      Provider<AuthRepository>(
        create: (context) => AuthRepository(
          Provider.of<Dio>(context, listen: false),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => PasswordRescueProvider(),
      ),
      ChangeNotifierProvider(
        create: (ctx) => CategoryViewmodel(
          CategoryRepository(Provider.of<Dio>(ctx, listen: false)),
          mapFailureToKey
        )
      ),
      Provider<AttachmentRepository>(
        create: (context) => AttachmentRepository(
            Provider.of<Dio>(context, listen: false),
            Provider.of<LocalAttachmentRepository>(context, listen: false)
        ),
      ),
      ChangeNotifierProvider(
        create: (ctx) => TaskViewmodel(
          TaskRepository(
            Provider.of<Dio>(ctx, listen: false),
            Provider.of<LocalAttachmentRepository>(ctx, listen: false),
            Provider.of<AttachmentRepository>(ctx, listen: false)
          ),
          notificationService,
          mapFailureToKey,
          Provider.of<CategoryViewmodel>(ctx, listen: false)
        ),
      ),
      ChangeNotifierProvider(
        create: (ctx) => HomeViewmodel(
          Provider.of<TaskViewmodel>(ctx, listen: false),
          Provider.of<CategoryViewmodel>(ctx, listen: false)
        ),
      ),
      ChangeNotifierProvider(
        create: (ctx) => CategoryFormViewmodel(
          mapFailureToKey,
          CategoryRepository(Provider.of<Dio>(ctx, listen: false))
        )
      ),
      ChangeNotifierProvider(
        create: (ctx) => PasswordRescueViewmodel(
          mapFailureToKey,
          Provider.of<AuthRepository>(ctx, listen: false)
        ),
      ),
      ChangeNotifierProvider(
        create: (ctx) => RegisterViewModel(
          mapFailureToKey,
          Provider.of<AuthRepository>(ctx, listen: false)
        ),
      ),
      ChangeNotifierProvider(
        create: (ctx) => LoginViewmodel(
          Provider.of<AuthService>(ctx, listen: false),
          Provider.of<AuthRepository>(ctx, listen: false),
          Provider.of<AuthProvider>(ctx, listen: false),
          mapFailureToKey
        ),
      ),
      ChangeNotifierProvider(
        create: (ctx) => PasswordResetViewmodel(
          Provider.of<AuthRepository>(ctx, listen: false),
          mapFailureToKey
        ),
      ),
      ChangeNotifierProvider(
        create: (ctx) => TaskDetailsViewmodel(
          Provider.of<AttachmentRepository>(ctx, listen: false),
          SubtaskRepository(Provider.of<Dio>(ctx, listen: false)),
          mapFailureToKey
        )
      ),
      ChangeNotifierProvider(
        create: (ctx) => TaskFormViewmodel(
          TaskRepository(
            Provider.of<Dio>(ctx, listen: false),
            Provider.of<LocalAttachmentRepository>(ctx, listen: false),
            Provider.of<AttachmentRepository>(ctx, listen: false)
          ),
          mapFailureToKey
        )
      )
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
    initializeInterceptorAndListeners();
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

  void initializeInterceptorAndListeners() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      final dio = Provider.of<Dio>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final authApiDioService = Provider.of<AuthRepository>(context, listen: false);
      final notificationService = Provider.of<NotificationService>(context, listen: false);

      notificationService.initNotificationPlugin(
        onNotificationTap: _onNotificationTap,
        onBackgroundNotificationTap: notificationTapBackground
      );

      _processPendingNotification();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final passwordRescueProvider = Provider.of<PasswordRescueProvider>(context, listen: false);

      dio.options.baseUrl = 'http://10.0.0.9:8080';
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

  void _processPendingNotification() async {
    print('[PROCESS PENDING] Checking for pending notification...');
    final prefs = await SharedPreferences.getInstance();
    final String? payload = prefs.getString(_pendingNotificationPayloadKey);

    print('[PROCESS PENDING] Found payload in SharedPreferences: $payload');

    if (payload != null && payload.isNotEmpty) {
      print('[PROCESS PENDING] Payload is valid, removing from prefs and calling handler.');
      await prefs.remove(_pendingNotificationPayloadKey);
      _onNotificationTap(payload);
    } else {
      print('[PROCESS PENDING] No valid payload found.');
    }
  }

  void _onNotificationTap(String? payload) {
    print('[_onNotificationTap] Handler called with payload: $payload');
    if (payload == null) return;

    final payloadData = jsonDecode(payload);
    final String id = payloadData['id'];
    final TaskType taskType = TaskType.values.firstWhere((e) => e.name == payloadData['taskType']);

    final taskViewModel = context.read<TaskViewmodel>();
    TaskVo? task;

    if (taskType == TaskType.t) {
      task = taskViewModel.findTaskById(id);
    } else if (taskType == TaskType.st) {
      task = taskViewModel.findParentTaskOfSubtask(id);
    }

    print('[_onNotificationTap] Found task: ${task?.title}');

    if (task != null) {
      print('[_onNotificationTap] Navigating to TaskDetailsScreen.');
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => TaskDetailsScreen(task: task!),
        ),
      );
    } else {
      print('[_onNotificationTap] Task not found, not navigating.');
    }
  }

  void _checkAndNavigateBasedOnDeepLink() {
    final passwordRescueProvider = context.read<PasswordRescueProvider>();

    final String? token = passwordRescueProvider.pendingRescueToken;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (token != null) {
        navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => PasswordResetScreen(rescueToken: token))
        ).then( (_) {passwordRescueProvider.clearRescueToken();}
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
        Locale('en', 'US'),
        Locale('pt', 'BR'),
        Locale('es')
      ],
      locale: preferencesProvider.appLanguage,
      home: Wrapper(),
    );
  }
}
