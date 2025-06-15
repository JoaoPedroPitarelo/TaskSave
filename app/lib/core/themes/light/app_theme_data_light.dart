import 'package:app/core/themes/light/app_colors_light.dart';
import 'package:app/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppThemeDataLight {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColorsLight.backgroundColorLight,
      colorScheme: ColorScheme.light(brightness: Brightness.light, primary: AppColorsLight.primary),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      brightness: Brightness.light,
    );
  }
}
