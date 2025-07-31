import 'package:animations/animations.dart';
import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/core/themes/dark/app_colors_dark.dart';
import 'package:task_save/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppThemeDataDark {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColorsDark.scaffoldBackgroundColor,
      colorScheme: ColorScheme.dark(
          brightness: Brightness.dark, primary: AppColorsDark.scaffoldPrimaryColor),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        // For tasks
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: AppTextStyles.labelSmall,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 8.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 10.0,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          elevation: 10,
        ),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SharedAxisPageTransitionsBuilder(
              transitionType: SharedAxisTransitionType.horizontal
          ),
          TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
              transitionType: SharedAxisTransitionType.horizontal
          ),
        },
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppGlobalColors(
          welcomeScreenCardColor: AppColorsDark.welcomeScreenCardColor,
          taskSaveLogo: AppColorsDark.taskSaveLogo,
          taskCardColor: AppColorsDark.taskCardColor,
          taskFooterColor: AppColorsDark.taskFooterColor,
          taskPriorityNeutralColor: AppColorsDark.taskPriorityNeutralColor,
          taskPriorityLowColor: AppColorsDark.taskPriorityLowColor,
          taskPriorityMediumColor: AppColorsDark.taskPriorityMediumColor,
          taskPriorityHighColor: AppColorsDark.taskPriorityHighColor
        ),
      ],
      brightness: Brightness.dark,
    );
  }
}
