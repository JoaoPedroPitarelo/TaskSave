import 'dart:async';
import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/core/utils/translateFailureKey.dart';
import 'package:task_save/core/events/auth_events.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/common/error_snackbar.dart';
import 'package:task_save/presentation/common/sucess_snackbar.dart';
import 'package:task_save/presentation/screens/password_change/password_change_viewmodel.dart';
import 'package:task_save/services/events/auth_event_service.dart';
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
  StreamSubscription? _passwordRescueSubscription;
  final AuthEventService _authEventService = AuthEventService();

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmedPassword = true;

  late AppLocalizations appLocalizations;
  bool _isInit = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordRescueSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      appLocalizations = AppLocalizations.of(context)!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _passwordRescueSubscription = _authEventService.onAuthChanged.listen( (event) {
          if (event is PasswordResetedEvent) {
            if (event.success) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(showSuccessSnackBar(appLocalizations.passwordReseted));
                Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
    final passwordRescueViewmodel = context.watch<PasswordResetViewmodel>();
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
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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

                              final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

                              if (!passwordRegex.hasMatch(value)) {
                                return AppLocalizations.of(context)!.invalidPasswordFormat;
                              }

                              return null;
                            },
                            autofillHints: [AutofillHints.password],
                          ),
                          TextFormField(
                            obscureText: _obscureTextConfirmedPassword,
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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
                    onPressed: passwordRescueViewmodel.isLoading ? null : () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      passwordRescueViewmodel.resetPassword(widget.rescueToken, _passwordController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      minimumSize: Size(350, 50),
                      backgroundColor: const Color.fromARGB(192, 2, 117, 33),
                    ),
                    child: passwordRescueViewmodel.isLoading ? CircularProgressIndicator()
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
