import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 450,
          child: Image.asset(
            "assets/images/tasksave_logo.png",
            height: 250,
            width: 250,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            textAlign: TextAlign.center,
            AppLocalizations.of(context)!.welcomeText,
            style: GoogleFonts.sansitaSwashed(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 25,
              textStyle: TextStyle(
                inherit: false,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.white,
                    size: 40,
                    weight: 200.0,
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/welcomeScreen2')),
            ),
          ],
        )
      ],
    );
  }
}
