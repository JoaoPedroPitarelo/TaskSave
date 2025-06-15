import 'package:app/core/themes/dark/app_colors_dark.dart';
import 'package:app/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppThemeDataDark {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColorsDark.backgroundColorDark,
      colorScheme: ColorScheme.dark(brightness: Brightness.dark, primary: AppColorsDark.primary),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        // For tasks
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      brightness: Brightness.dark,
    );
  }
  
}