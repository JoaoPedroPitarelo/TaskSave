import 'package:app/presentation/views/login/login_viewmodel.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/l10n/app_localizations.dart';
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
    return Consumer<LoginViewModel>( // consumindo da classe AuthProvider
      builder: (context, provider, _) {

        final theme = Theme.of(context);

        final imagePath = theme.brightness == Brightness.dark ? "assets/images/tasksave_logo_light.png"
                                                          : "assets/images/tasksave_logo_dark.png";



        // traduzindo addPostFrameCallback = adicione depois do primeiro frame ser montado
        // desse jeito evitamos de mostrar algo que ainda não está completamento montado, pois estamos no método build()
        // então ele só executar isso após o primeiro frame do widget ser montado
        if (provider.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) { 
            Navigator.of(context).pushReplacementNamed("/home");
          });
        }

        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print(provider.errorMessage);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.errorMessage!.toString(),
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                  ),
                ), 
                action: SnackBarAction(
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                  }, 
                  label: "OK",
                  textColor: Colors.white,
                ),
                duration: Duration(seconds: 2),
                backgroundColor: const Color.fromARGB(255, 176, 35, 24),),
            );
            provider.clearError(); // impede que mostre o snackbar toda hora
          });
        }

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
                          imagePath, 
                          width: 250, height: 250, 
                          alignment: Alignment.center
                        ),
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
                                    if (value == null || value.isEmpty) { return AppLocalizations.of(context)!.emailIsObrigatoryValue; } 
                              
                                    if (!EmailValidator.validate(value)) { return AppLocalizations.of(context)!.invalidEmail; }
                                    
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
                                    if (value == null || value.isEmpty) { return AppLocalizations.of(context)!.passwordIsObrigatoryValue; } 
                                    
                                    return null;
                                  },
                                  autofillHints: [AutofillHints.password],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // TODO Fazer tela de redefinição de senha
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
                          onPressed: provider.isLoading ? null : () async {
                            if (!_formkey.currentState!.validate()) { // valida todos os campos do formulário
                              return;
                            }
                              
                            await provider.doLogin(_loginController.text, _passwordController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            minimumSize: Size(350, 50),
                            backgroundColor: Color.fromARGB(255, 61, 64, 254)
                          ),
                          child: provider.isLoading 
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
                              RichText(
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
    );
  }
}
