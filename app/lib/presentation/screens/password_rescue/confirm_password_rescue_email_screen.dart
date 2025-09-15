import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ConfirmPasswordRescueEmailScreen extends StatelessWidget {
  const ConfirmPasswordRescueEmailScreen({super.key});

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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 0.8, offset: Offset(0, 1.3))
                    ],
                    color: Color.fromARGB(255, 61, 64, 254),
                    size: 180,
                  ),
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      AppLocalizations.of(context)!.passwordEmailSent,
                      style: theme.textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: Divider(thickness: 1.2),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
