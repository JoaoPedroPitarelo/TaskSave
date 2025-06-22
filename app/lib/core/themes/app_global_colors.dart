import 'package:flutter/material.dart';

@immutable
class AppGlobalColors extends ThemeExtension<AppGlobalColors> {
  final String? taskSaveLogo;
  final Color? welcomeScreenCardColor;
  // Task
  final Color? taskCardColor;
  final Color? taskFooterColor;
  final Color? taskPriorityNeutralColor;
  final Color? taskPriorityLowColor;
  final Color? taskPriorityMediumColor;
  final Color? taskPriorityHighColor;

  const AppGlobalColors({
    this.taskSaveLogo,
    this.welcomeScreenCardColor,
    // Task
    this.taskCardColor,
    this.taskFooterColor,
    this.taskPriorityNeutralColor,
    this.taskPriorityLowColor,
    this.taskPriorityMediumColor,
    this.taskPriorityHighColor
  });

  @override
  ThemeExtension<AppGlobalColors> copyWith({
    String? taskSaveLogo,
    Color? welcomeScreenCardColor,
    // Task
    Color? taskCardColor,
    Color? taskFooterColor,
    Color? taskPriorityNeutralColor,
    Color? taskPriorityLowColor,
    Color? taskPriorityMediumColor,
    Color? taskPriorityHighColor
  }) {
    return AppGlobalColors(
     taskSaveLogo: taskSaveLogo ?? this.taskSaveLogo,
     welcomeScreenCardColor: welcomeScreenCardColor ?? this.welcomeScreenCardColor,
     // Task
     taskCardColor: taskCardColor ?? this.taskCardColor,
     taskFooterColor: taskFooterColor ?? this.taskFooterColor,
     taskPriorityNeutralColor: taskPriorityNeutralColor ?? this.taskPriorityNeutralColor,
     taskPriorityLowColor: taskPriorityLowColor ?? this.taskPriorityLowColor,
     taskPriorityMediumColor: taskPriorityMediumColor ?? this.taskPriorityMediumColor,
     taskPriorityHighColor: taskPriorityHighColor ?? this.taskPriorityHighColor 
    );
  }
  
  @override
  ThemeExtension<AppGlobalColors> lerp(covariant ThemeExtension<AppGlobalColors>? other, double t) {
    if (other is! AppGlobalColors) {
      return this;
    }
    return AppGlobalColors(
      welcomeScreenCardColor: Color.lerp(welcomeScreenCardColor, other.welcomeScreenCardColor, t),
      // Task
      taskCardColor: Color.lerp(taskCardColor, other.taskCardColor, t),
      taskFooterColor: Color.lerp(taskFooterColor, other.taskFooterColor, t),
      taskPriorityNeutralColor: Color.lerp(taskPriorityNeutralColor, other.taskPriorityNeutralColor, t),
      taskPriorityLowColor: Color.lerp(taskPriorityLowColor, other.taskPriorityLowColor, t),
      taskPriorityMediumColor: Color.lerp(taskPriorityMediumColor, other.taskPriorityMediumColor, t),
      taskPriorityHighColor: Color.lerp(taskPriorityHighColor, other.taskPriorityHighColor, t)
    );
  }

  static AppGlobalColors of(BuildContext context) {
    return Theme.of(context).extension<AppGlobalColors>()!;
  }
}
