import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/presentation/screens/welcome/fourth_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ThirdWelcomeScreen extends StatelessWidget {
  const ThirdWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = AppGlobalColors.of(context);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            child: SizedBox(
              child: Image.asset(
                appColors.taskSaveLogo!,
                width: 250,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: appColors.welcomeScreenCardColor
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, 
                  spacing: 20,               
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        AppLocalizations.of(context)!.createYourCategories,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      height: 500,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.0),
                        child: Image.asset("assets/images/list_categories_example.png")
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded, size: 40, weight: 200.0),
                  onPressed: () => Navigator.of(context).pop()
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded, size: 40, weight: 200.0),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FourthWelcomeScreen())
                  )
                ),
              ),
            ]
          )
        ],
      ),
    );
  }
}
