import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';

class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final imagePath = theme.brightness == Brightness.dark ? "assets/images/tasksave_logo_light.png" 
                                                          : "assets/images/tasksave_logo_dark.png";
    
    final colorButton = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 450,
            child: Image.asset(
              imagePath,
              height: 250,
              width: 250,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              textAlign: TextAlign.center,
              AppLocalizations.of(context)!.welcomeText,
              style: theme.textTheme.displayLarge,
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
                      color: colorButton,
                      size: 40,
                      weight: 200.0,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/welcomeScreen2')),
              ),
            ],
          )
        ],
      ),
    );
  }
}
