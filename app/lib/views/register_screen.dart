import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _loginController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
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
                          "Register",
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
                                  return "E-mail is a obrigatory values";
                                } 
                                // TODO fazer verificação para ver se é um email válido
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
                                if (value == null || value.isEmpty) {
                                  return "Password is a obrigatory values";
                                } 
                                // TODO fazer verificação para ver se é um email válido
                                return null;
                              },
                              autofillHints: [AutofillHints.password],
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
                                labelText: AppLocalizations.of(context)!.confirmPassoword,
                              ),
                              keyboardType: TextInputType.visiblePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is a obrigatory values";
                                } 
                                // TODO fazer verificação para ver se é um email válido
                                return null;
                              },
                              autofillHints: [AutofillHints.password],
                            )
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {}, 
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                        ),
                        minimumSize: Size(350, 50),
                        backgroundColor: Color.fromARGB(255, 61, 254, 116)
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.register,
                        style: GoogleFonts.roboto(
                          color: Colors.black,
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
