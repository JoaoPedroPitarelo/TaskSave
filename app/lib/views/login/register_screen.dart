import 'package:app/core/exceptions/duplicated_user_exception.dart';
import 'package:app/core/exceptions/passwords_are_not_same_exception.dart';
import 'package:app/providers/register_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formkey = GlobalKey<FormState>();

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
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterProvider>(
      builder: (context, auth, _) {
        
        // Fazendo aqui dentro por que é preciso tem o context para usar o AppLocalization.of(context)
        String getTranslatedErrorMessage(Object exc) {
          if (exc is DuplicatedUserException) { 
            return AppLocalizations.of(context)!.duplicatedUser;
          }
          if (exc is PasswordsAreNotSameException) {
            return AppLocalizations.of(context)!.passwordAreNotTheSame;
          }
          return AppLocalizations.of(context)!.unknownError;
        } 

        if (auth.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) { 
            Navigator.of(context).pushReplacementNamed("/confirmEmail");
          });
        }

        if (auth.error != null) {
          WidgetsBinding.instance.addPostFrameCallback( (_) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  getTranslatedErrorMessage(auth.error!),
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                  ),
                ),
                action: SnackBarAction(
                  label: "OK", 
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                  },
                  textColor: Colors.white,
                ),
                duration: Duration(seconds: 2),
                backgroundColor: const Color.fromARGB(255, 176, 35, 24)
              )
            );
            auth.clearError();
          });
        }

        return Scaffold(
          backgroundColor: Colors.black,
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
                                icon: Icon(Icons.arrow_back_outlined, color: Colors.white, size: 30),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        Image.asset('assets/images/tasksave_logo.png', width: 250, height: 154, alignment: Alignment.topCenter),
                        Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.register,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 38
                              ),
                            ),
                            Container(color: Colors.white, width: 350, height: 1.6)
                          ],
                        ),
                        Form(
                          key: _formkey,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                            child: Column(
                              spacing: 16,
                              children: [
                                TextFormField(
                                  controller: _loginController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.email_outlined, color: Colors.white,),
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
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.password_outlined, color: Colors.white,),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureTextPassword = !_obscureTextPassword;
                                        });
                                      }, 
                                      icon: Icon(_obscureTextPassword ? Icons.visibility : Icons.visibility_off, color: Colors.white,),
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
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.password_outlined, color: Colors.white,),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureTextConfirmedPassword = !_obscureTextConfirmedPassword;
                                        });
                                      }, 
                                      icon: Icon(_obscureTextConfirmedPassword ? Icons.visibility : Icons.visibility_off, color: Colors.white,),
                                    ),
                                    fillColor: const Color.fromARGB(31, 187, 187, 187),
                                    labelText: AppLocalizations.of(context)!.confirmPassoword,
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!.confirmPassoword;
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
                          onPressed: auth.isLoading ? null : () {
                            if (!_formkey.currentState!.validate()) { 
                              return;
                            }
        
                            auth.createLogin(_loginController.text, _passwordController.text, _confirmPasswordController.text);
                          }, 
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            minimumSize: Size(350, 50),
                            backgroundColor: Color.fromARGB(255, 61, 254, 116)
                          ),
                          child: auth.isLoading ? CircularProgressIndicator()
                          : Text(
                            AppLocalizations.of(context)!.registerButton,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
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
    );
  }
}


