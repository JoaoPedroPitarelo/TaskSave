import 'dart:async';
import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/core/utils/translateFailureKey.dart';
import 'package:app/core/events/auth_events.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/common/error_snackbar.dart';
import 'package:app/presentation/common/sucess_snackbar.dart';
import 'package:app/presentation/screens/password_rescue/confirm_password_rescue_email_screen.dart';
import 'package:app/presentation/screens/password_rescue/password_rescue_viewmodel.dart';
import 'package:app/services/events/auth_event_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PasswordRescueScreen extends StatefulWidget {
  const PasswordRescueScreen({super.key});

  @override
  State<PasswordRescueScreen> createState() => _PasswordRescueScreenState();
}

class _PasswordRescueScreenState extends State<PasswordRescueScreen> {
  StreamSubscription? _passwordRescueSubscription;
  final AuthEventService _authEventService = AuthEventService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late AppLocalizations appLocalizations;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      appLocalizations = AppLocalizations.of(context)!;

      WidgetsBinding.instance.addPostFrameCallback( (_) {
        _passwordRescueSubscription = _authEventService.onAuthChanged.listen( (event) {
          if (event is PasswordRescueEvent) {
            if (event.success) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(showSuccessSnackBar(appLocalizations.passwordRescueSuccess));
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConfirmPasswordRescueEmailScreen()));
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
    _emailController.dispose();
    _passwordRescueSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordRescueViewModel = context.watch<PasswordRescueViewmodel>();
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
                          AppLocalizations.of(context)!.passwordRescue,
                          style: theme.textTheme.displayLarge
                      ),
                      SizedBox(
                        width: 350,
                        child: Divider(
                          thickness: 1.2,
                          endIndent: 0.5,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
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
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: passwordRescueViewModel.isLoading ? null : () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      passwordRescueViewModel.doPasswordRescue(_emailController.text);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        minimumSize: Size(350, 50),
                        backgroundColor: Color.fromARGB(255, 0, 101, 32)
                    ),
                    child: passwordRescueViewModel.isLoading ? CircularProgressIndicator()
                        : Text(
                      AppLocalizations.of(context)!.sendRescueEmail,
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
