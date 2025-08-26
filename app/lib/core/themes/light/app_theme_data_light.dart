import 'package:animations/animations.dart';
import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/core/themes/light/app_colors_light.dart';
import 'package:task_save/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppThemeDataLight {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColorsLight.scaffoldBackgroundColor,
      colorScheme: ColorScheme.light(brightness: Brightness.light, primary: AppColorsLight.scaffoldPrimaryColor),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsLight.scaffoldAppBarColor
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        // for tasks
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: AppTextStyles.labelSmall,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 10.0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
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
          welcomeScreenCardColor: AppColorsLight.welcomeScreenCardColor,
          taskSaveLogo: AppColorsLight.taskSaveLogo,
          taskCardColor: AppColorsLight.taskCardColor,
          taskFooterColor: AppColorsLight.taskFooterColor,
          taskPriorityNeutralColor: AppColorsLight.taskPriorityNeutralColor,
          taskPriorityLowColor: AppColorsLight.taskPriorityLowColor,
          taskPriorityMediumColor: AppColorsLight.taskPriorityMediumColor,
          taskPriorityHighColor: AppColorsLight.taskPriorityHighColor
        ),
      ],
      brightness: Brightness.light,
    );
  }
}
