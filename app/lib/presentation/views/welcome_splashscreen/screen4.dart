import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

// TODO Quando a norificação estiver pronta, colocar neste Widget um exemplo de notificação do android

class Screen4 extends StatelessWidget {
  const Screen4({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final imagePath = theme.brightness == Brightness.dark ? "assets/images/tasksave_logo_light.png"
                                                          : "assets/images/tasksave_logo_dark.png";

    final colorButton = theme.brightness == Brightness.dark ? Colors.white : Colors.black;


    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 170,
            child: Image.asset(
              imagePath, 
              height: 250, width: 250,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  color: Color.fromARGB(255, 82, 82, 82),
                  ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 200,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Text(
                        AppLocalizations.of(context)!.notified,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sansitaSwashed(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          textStyle: TextStyle(
                            inherit: false,
                          )
                        ),
                      ),
                    )
                  ],
                ),
                ),
              )
            ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: colorButton,
                    size: 40,
                    weight: 200.0,
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/welcomeScreen3')),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_outlined,
                      color: colorButton, size: 40, weight: 200.0),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/finalWelcomeScreen')),
            ),
          ]
        )
      ]),
    );
  }
}