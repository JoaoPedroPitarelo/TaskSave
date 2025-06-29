import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/core/utils/failure_localizations_mapper.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/screens/login/login_screen.dart';
import 'package:app/presentation/screens/login/login_viewmodel.dart';
import 'package:app/presentation/screens/password_change/password_change_viewmodel.dart';
import 'package:app/repositories/auth_repository.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PasswordResetScreen extends StatefulWidget {
  final String rescueToken;

  const PasswordResetScreen({
    required this.rescueToken, 
    super.key
  });

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmedPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final passswordRescueViewmodel = context.watch<PasswordResetViewmodel>();
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);

    if (passswordRescueViewmodel.isPasswordReseted) {
      WidgetsBinding.instance.addPostFrameCallback((_) { 
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.passwordReseted,
              style: theme.textTheme.labelSmall
            ),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.green
          )
        );
      
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (ctx) => LoginViewModel(
                Provider.of<AuthService>(ctx, listen: false),
                Provider.of<AuthRepository>(ctx, listen: false),
                Provider.of<AuthProvider>(ctx, listen: false),
                  (failure) => mapFailureToLocalizationMessage(ctx, failure)
              ),
              child: const LoginScreen(),
            )
          )
        );
       }
      );
      passswordRescueViewmodel.isPasswordReseted = false;
    }

    if (passswordRescueViewmodel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback( (_) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              passswordRescueViewmodel.errorMessage.toString(),
              style:
              theme.textTheme.labelSmall
            ),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.red
          )
        );
        passswordRescueViewmodel.clearErrorMessage();
      });
    }

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
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 0, left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(
                                Icons.arrow_back_outlined,
                                size: 30
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                        appColors.taskSaveLogo!,
                        width: 250, height: 154,
                        alignment: Alignment.topCenter
                    ),
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.resetPassword,
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
                              obscureText: _obscureTextPassword,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.password_outlined),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureTextPassword = !_obscureTextPassword;
                                    });
                                  },
                                  icon: Icon(_obscureTextPassword ? Icons.visibility : Icons.visibility_off),
                                ),
                                fillColor: const Color.fromARGB(31, 187, 187, 187),
                                labelText: AppLocalizations.of(context)!.newPassword,
                              ),
                              keyboardType: TextInputType.visiblePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.passwordIsObrigatoryValue;
                                }
                                if (value.length < 8) {
                                  return AppLocalizations.of(context)!.minimumLengthPassword;
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return AppLocalizations.of(context)!.minimumCapitalLetter;
                                }
                                if (!RegExp(r'[!@#$%^*(),.?":{}|<>]').hasMatch(value)) {
                                  return AppLocalizations.of(context)!.minimumEspecialCaractere;
                                }
                                if (!RegExp(r'\d').hasMatch(value)) {
                                  return AppLocalizations.of(context)!.minimumDigit;
                                }
                                return null;
                              },
                              autofillHints: [AutofillHints.password],
                            ),
                            TextFormField(
                              obscureText: _obscureTextConfirmedPassword,
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.password_outlined),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureTextConfirmedPassword = !_obscureTextConfirmedPassword;
                                    });
                                  },
                                  icon: Icon(_obscureTextConfirmedPassword ? Icons.visibility : Icons.visibility_off),
                                ),
                                fillColor: const Color.fromARGB(31, 187, 187, 187),
                                labelText: AppLocalizations.of(context)!.confirmPassoword,
                              ),
                              keyboardType: TextInputType.visiblePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.confirmPassoword;
                                }

                                if (value != _passwordController.text) {
                                  return AppLocalizations.of(context)!.passwordAreNotTheSame;
                                }

                                return null;
                              },
                              autofillHints: [AutofillHints.password],
                            )
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: passswordRescueViewmodel.isLoading ? null : () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        passswordRescueViewmodel.resetPassword(widget.rescueToken, _passwordController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                        ),
                        minimumSize: Size(350, 50),
                        backgroundColor: Color.fromARGB(255, 0, 101, 32)
                      ),
                      child: passswordRescueViewmodel.isLoading ? CircularProgressIndicator()
                      : Text(
                        AppLocalizations.of(context)!.confirm,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 25
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
