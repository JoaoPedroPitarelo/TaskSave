import 'package:app/core/themes/app_colors.dart';
import 'package:app/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppThemeData {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(brightness: Brightness.light, primary: AppColors.primary),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      brightness: Brightness.light,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.dark(brightness: Brightness.dark, primary: AppColors.primary),
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