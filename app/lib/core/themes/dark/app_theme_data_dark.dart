import 'package:animations/animations.dart';
import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/core/themes/dark/app_colors_dark.dart';
import 'package:task_save/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppThemeDataDark {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColorsDark.scaffoldBackgroundColor,
      colorScheme: ColorScheme.dark(brightness: Brightness.dark, primary: AppColorsDark.scaffoldPrimaryColor),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsDark.scaffoldAppBarColor
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColorsDark.taskCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        dayOverlayColor: WidgetStateProperty.all(Colors.transparent),
        dayShape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // raio da célula selecionada
          ),
        ),
        confirmButtonStyle: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 105, 223, 79)),
          textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.bold))
        ),
        cancelButtonStyle: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 207, 56, 56)),
          textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.bold))
        )
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), 
        ),
        backgroundColor: const Color.fromARGB(255, 57, 57, 57),
      ),
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
      useMaterial3: true,
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: AppTextStyles.labelSmall,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 10.0,
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
