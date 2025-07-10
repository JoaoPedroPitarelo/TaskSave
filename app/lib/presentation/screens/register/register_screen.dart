import 'dart:async';

import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/core/utils/translateFailureKey.dart';
import 'package:app/core/events/auth_events.dart';
import 'package:app/presentation/common/error_snackbar.dart';
import 'package:app/presentation/common/sucess_snackbar.dart';
import 'package:app/presentation/screens/register/confirm_register_email_screen.dart';
import 'package:app/services/events/auth_event_service.dart';
import 'register_viewmodel.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  StreamSubscription? _registerSubscription;
  final AuthEventService _authEventService = AuthEventService();

  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmedPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _loginController.dispose();
    _confirmPasswordController.dispose();
    _registerSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerSubscription = _authEventService.onAuthChanged.listen((event) {
        if (event is RegisterEvent) {
          if (event.success){
            ScaffoldMessenger.of(context).showSnackBar(
                showSuccessSnackbar(AppLocalizations.of(context)!.registerSuccess)
            );
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConfirmRegisterEmailScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              showErrorSnackbar(translateFailureKey(context, event.failureKey!))
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final registerViewmodel = context.watch<RegisterViewModel>();
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
                        AppLocalizations.of(context)!.register,
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
                            controller: _loginController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              fillColor: const Color.fromARGB(31, 187, 187, 187),
                              labelText: AppLocalizations.of(context)!.enterEmail,
                              hintText: AppLocalizations.of(context)!.enterEmailExample
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.emailIsObrigatoryValue;
                              }

                              if (!EmailValidator.validate(value)) {
                                return AppLocalizations.of(context)!.invalidEmail;
                              }

                              return null;
                            },
                            autofillHints: [AutofillHints.email],
                          ),
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
                              labelText: AppLocalizations.of(context)!.enterPassword,
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
                    onPressed: registerViewmodel.isLoading ? null : () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      registerViewmodel.createLogin(_loginController.text, _passwordController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      minimumSize: Size(350, 50),
                      backgroundColor: Color.fromARGB(255, 0, 101, 32)
                    ),
                    child: registerViewmodel.isLoading ? CircularProgressIndicator()
                    : Text(
                      AppLocalizations.of(context)!.registerButton,
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
