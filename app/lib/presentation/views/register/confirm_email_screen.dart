import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmEmailScreen extends StatelessWidget {
  const ConfirmEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final imagePath = theme.brightness == Brightness.dark ? "assets/images/tasksave_logo_light.png"
                                                          : "assets/images/tasksave_logo_dark.png";
    return Scaffold(
        body: Center(
          child: Column(
            // envolve o column em um Center, pois por padrão o column não ocupa todo o espaço horizontal que tem
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40, left: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_outlined,
                          color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Image.asset(imagePath, 
                width: 250, 
                alignment: Alignment.center
              ),
              Column(
                children: [
                  Image.asset('assets/images/confirm_email.png',
                      width: 290, height: 400, alignment: Alignment(9, 0)),
                  SizedBox(height: 50),
                  Text(
                    AppLocalizations.of(context)!.good,
                    style: GoogleFonts.schibstedGrotesk(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.confirmEmail,
                    style: GoogleFonts.schibstedGrotesk(
                        color: Colors.white, fontSize: 28),
                  ),
                  Container(
                    width: 380,
                    height: 1.2,
                    color: Colors.white,
                  )
                ],
              )
            ],
          ),
        ));
  }
}
