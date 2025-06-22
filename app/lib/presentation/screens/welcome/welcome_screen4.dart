import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/core/utils/failure_localizations_mapper.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/screens/login/login_screen.dart';
import 'package:app/presentation/screens/login/login_viewmodel.dart';
import 'package:app/presentation/screens/welcome/final_welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_api_dio_service.dart';
import '../../../services/auth_service.dart';

// TODO Quando a norificação estiver pronta, colocar neste Widget um exemplo de notificação do android

class WelcomeScreen4 extends StatelessWidget {
  const WelcomeScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = AppGlobalColors.of(context);

    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 170,
          child: Image.asset(
            appColors.taskSaveLogo!,
            height: 250,
            width: 250,
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: 500,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                color:appColors.welcomeScreenCardColor
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 200,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(AppLocalizations.of(context)!.notified,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium
                  ),
                )
              ],
            ),
          ),
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_outlined,
                    size: 40,
                    weight: 200.0,
                  ),
                  onPressed: () => Navigator.of(context).pop()
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 40, 
                    weight: 200.0
                  ),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FinalWelcomeScreen()
                    )
                  )
              ),
            ),
          ]
        )
      ]),
    );
  }
}
