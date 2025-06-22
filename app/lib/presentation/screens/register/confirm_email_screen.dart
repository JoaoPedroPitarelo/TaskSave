import 'package:app/core/themes/app_global_colors.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmEmailScreen extends StatelessWidget {
  const ConfirmEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = AppGlobalColors.of(context);

    return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40, left: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_outlined, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Image.asset(
                appColors.taskSaveLogo!,
                width: 250, 
                alignment: Alignment.center
              ),
              Column(
                children: [
                  Image.asset(
                      'assets/images/confirm_email.png',
                      width: 290, height: 400,
                      alignment: Alignment(9, 0)
                  ),
                  SizedBox(height: 50),
                  Text(
                    AppLocalizations.of(context)!.good,
                    style: theme.textTheme.displayMedium
                  ),
                  Text(
                    AppLocalizations.of(context)!.confirmEmail,
                    style: theme.textTheme.displayMedium
                  ),
                  SizedBox(
                    width: 350,
                    child: Divider(
                      thickness: 1.2,
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
