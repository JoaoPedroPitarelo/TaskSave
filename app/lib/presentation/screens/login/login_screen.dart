import 'dart:async';
import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/core/utils/translateFailureKey.dart';
import 'package:task_save/core/events/auth_events.dart';
import 'package:task_save/presentation/common/error_snackbar.dart';
import 'package:task_save/presentation/common/sucess_snackbar.dart';
import 'package:task_save/presentation/screens/password_rescue/password_rescue_screen.dart';
import 'package:task_save/presentation/screens/register/register_screen.dart';
import 'package:task_save/services/events/auth_event_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription? _loginSubscription;
  final AuthEventService _authEventService = AuthEventService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  late AppLocalizations appLocalizations;
  bool _isInit = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loginViewModel = context.read<LoginViewmodel>();
    await loginViewModel.doLogin(_emailController.text, _passwordController.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      appLocalizations = AppLocalizations.of(context)!;

      WidgetsBinding.instance.addPostFrameCallback( (_) {
        _loginSubscription = _authEventService.onAuthChanged.listen( (event) {

          if (event is LoginEvent) {
            if (event.success) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(showSuccessSnackBar(appLocalizations.loginSuccess));
                Navigator.of(context).popUntil((screen) => screen.isFirst);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(showErrorSnackBar(translateFailureKey(appLocalizations, event.failureKey!)));
              }
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _loginSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewmodel>();
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                         MediaQuery.of(context).padding.top -
                         MediaQuery.of(context).padding.bottom
            ),
            child: IntrinsicHeight(
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    appColors.taskSaveLogo!,
                    width: 250, height: 250,
                    alignment: Alignment.center
                  ),
                  Column(
                    children: [
                      Text(
                        "Login",
                        style: theme.textTheme.displayLarge
                      ),
                      SizedBox(
                        width: 350,
                        child: Divider(
                          thickness: 1.2,
                          endIndent: 0.5,
                        ),
                      )
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: Column(
                        spacing: 16,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              prefixIcon: Icon(Icons.email_outlined),
                              fillColor: const Color.fromARGB(31, 187, 187, 187),
                              labelText: AppLocalizations.of(context)!.enterEmail,
                              hintText: AppLocalizations.of(context)!.enterEmailExample
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) { return AppLocalizations.of(context)!.emailIsObrigatoryValue; }

                              if (!EmailValidator.validate(value)) { return AppLocalizations.of(context)!.invalidEmail; }

                              return null;
                            },
                            autofillHints: [AutofillHints.email],
                          ),
                          TextFormField(
                            obscureText: _obscureText,
                            controller: _passwordController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              prefixIcon: Icon(Icons.password_outlined),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                              ),
                              fillColor: const Color.fromARGB(31, 187, 187, 187),
                              labelText: AppLocalizations.of(context)!.enterPassword,
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.passwordIsObrigatoryValue;
                              }

                              return null;
                            },
                            autofillHints: [AutofillHints.password],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => PasswordRescueScreen()
                                    )
                                  );
                                },
                                autofocus: false,
                                child: Text(
                                    AppLocalizations.of(context)!.forgetPassword,
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.displaySmall
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: loginViewModel.isLoading ? null : () => _handleLogin(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: Size(350, 50),
                      backgroundColor: const Color.fromARGB(200, 25, 56, 189),
                    ),
                    child: loginViewModel.isLoading
                    ?  CircularProgressIndicator()
                    : Text(
                      AppLocalizations.of(context)!.login,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 30
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterScreen())),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: Size(350, 50),
                      backgroundColor: const Color.fromARGB(192, 2, 117, 33),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.registerButton,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 30
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


