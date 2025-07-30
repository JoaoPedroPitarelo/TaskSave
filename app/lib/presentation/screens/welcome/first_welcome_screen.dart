import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/presentation/screens/welcome/second_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:task_save/l10n/app_localizations.dart';

class FirstWelcomeScreen extends StatelessWidget {
  const FirstWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = AppGlobalColors.of(context);
    
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 450,
            child: Image.asset(
              appColors.taskSaveLogo!,
              height: 250,
              width: 250,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              textAlign: TextAlign.center,
              AppLocalizations.of(context)!.welcomeText,
              style: theme.textTheme.displayMedium,
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
                      size: 40,
                      weight: 200.0,
                    ),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SecondWelcomeScreen())
                    )
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
