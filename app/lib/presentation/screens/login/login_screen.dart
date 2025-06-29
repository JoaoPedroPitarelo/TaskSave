import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/core/utils/failure_localizations_mapper.dart';
import 'package:app/presentation/screens/password_rescue/password_rescue_screen.dart';
import 'package:app/presentation/screens/password_rescue/password_rescue_viewmodel.dart';
import 'package:app/presentation/screens/register/register_screen.dart';
import 'package:app/presentation/screens/register/register_viewmodel.dart';
import 'package:app/repositories/auth_repository.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loginViewModel = context.read<LoginViewModel>();
    await loginViewModel.doLogin(_emailController.text, _passwordController.text);
    final theme = Theme.of(context);

    if (loginViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
          content: Text(
            loginViewModel.errorMessage!.toString(),
            style: theme.textTheme.labelSmall,
          ),
         backgroundColor: Colors.red,
         width: MediaQuery.of(context).size.width * 0.95,
       ),
      );
      return;
    }

    showSnackBarOnSuccessLogin(context);
    Navigator.of(context).popUntil((screen) => screen.isFirst);
  }

  void showSnackBarOnSuccessLogin(BuildContext context) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
            AppLocalizations.of(context)!.loginSuccess,
            style: theme.textTheme.labelSmall,
          ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ConstrainedBox( // "Caixa com regras"
            constraints: BoxConstraints( // regras:
              minHeight: MediaQuery.of(context).size.height - // mediaQuery recuperada algumas informações do dispositivos em que o app esta rodando, como tamanho de tela, dpi, e modo escuro
                         MediaQuery.of(context).padding.top -
                         MediaQuery.of(context).padding.bottom
            ),
            child: IntrinsicHeight( // "altura intrisica" possibilita que os filhos cresçam em altura naturalmente
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
                                      builder: (context) => ChangeNotifierProvider(
                                        create: (ctx) => PasswordRescueViewmodel(
                                          (failure) => mapFailureToLocalizationMessage(ctx, failure),
                                          Provider.of<AuthRepository>(context, listen: false)
                                        ),
                                        child: PasswordRescueScreen()
                                        )
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
                      onPressed: loginViewModel.isLoading ? null : () => _handleLogin(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: Size(350, 50),
                        backgroundColor: Color.fromARGB(255, 12, 43, 170),
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
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.dontHaveAccount,
                                style: theme.textTheme.displaySmall,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                                    create: (ctx) => RegisterViewModel(
                                      (failure) => mapFailureToLocalizationMessage(ctx, failure),
                                      Provider.of<AuthRepository>(ctx, listen: false)
                                    ),
                                    child: RegisterScreen()
                                    )
                                  )
                                );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.createNow,
                                )
                              )
                            ],
                          )
                        ],
                      )
                    )
                  ],
                ),
            ),
          ),
        ),
      ),
    );
  }
}


