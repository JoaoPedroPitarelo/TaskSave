import 'package:app/providers/auth_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _loginController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>( // consumindo da classe AuthProvider
      builder: (context, auth, _) {

        if (auth.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed("/home");
          });
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/tasksave_logo.png', width: 250, height: 250, alignment: Alignment.center),
                  Column(
                    children: [
                      Text(
                        "Login",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 38
                        ),
                      ),
                      Container(color: Colors.white, width: 350, height: 1.6)
                    ],
                  ),
                  if (auth.errorMessage != null)
                    Text(
                      auth.errorMessage!,
                      style: TextStyle(color: Colors.red),
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
                              if (value == null || value.isEmpty) { return "E-mail is a obrigatory values"; } 

                              if (!EmailValidator.validate(value)) { return "Invalid e-mail"; }
                              
                              return null;
                            },
                            autofillHints: [AutofillHints.email],
                          ),
                          TextFormField(
                            obscureText: _obscureText,
                            controller: _passwordController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.password_outlined, color: Colors.white,),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                }, 
                                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.white,),
                              ),
                              fillColor: const Color.fromARGB(31, 187, 187, 187),
                              labelText: AppLocalizations.of(context)!.enterPassword,
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) { return "Password is a obrigatory values"; } 
                              
                              return null;
                            },
                            autofillHints: [AutofillHints.password],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // TODO Fazer tela de redefinição de tela
                                  print("redefenir senha...");
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.forgetPassword,
                                  textAlign: TextAlign.end,
                                  style: GoogleFonts.roboto(color: Colors.white, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : () async {
                      if (!_formkey.currentState!.validate()) { // valida todos os campos do formulário
                        print("preencha todos os campos!");
                        return;
                      }

                      await auth.doLogin(_loginController.text, _passwordController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      minimumSize: Size(350, 50),
                      backgroundColor: Color.fromARGB(255, 61, 64, 254)
                    ),
                    child: auth.isLoading 
                      ?  CircularProgressIndicator(color: Colors.white)
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          child: RichText(
                            text: TextSpan(
                              text: AppLocalizations.of(context)!.dontHaveAccount,
                              style: GoogleFonts.roboto(
                                fontSize: 16
                              ),
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!.createNow,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 35, 39, 255),
                                    textStyle: TextStyle(inherit: true)
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).pushNamed("/register");
                                    },
                                )
                              ]
                            ),
                          ),
                        )
                      ],
                    )
                  )
                ],
              ),
          ),
        );
      }
    );
  }
}
