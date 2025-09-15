import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/category_vo.dart';
import 'package:task_save/domain/enums/priority_enum.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/presentation/screens/welcome/third_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/common/task_widget.dart';

class SecondWelcomeScreen extends StatelessWidget {
  const SecondWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final appColors = AppGlobalColors.of(context);
   
    final lightCategoryColor = "#CCCCCC";
    final darkCategoryColor = "#3B3B3B";

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            child: SizedBox(
              child: Image.asset(appColors.taskSaveLogo!, width: 250)
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: appColors.welcomeScreenCardColor,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 80, right: 80),
                      child: Text(
                        AppLocalizations.of(context)!.addYourTask,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TaskWidget(
                            task: TaskVo(
                              id: "0",
                              title: AppLocalizations.of(context)!.makeCakeTitle,
                              description: AppLocalizations.of(context)!.makeCakeDescription,
                              deadline: DateTime(2025, 10, 10),
                              priority: PriorityEnum.neutral,
                              category: CategoryVo(
                                id: 0,
                                description: '',
                                color: theme.brightness != Brightness.dark
                                  ? darkCategoryColor
                                  : lightCategoryColor,
                                isDefault: false,
                                activate: true,
                                position: -1
                              ),
                              reminderType: ReminderTypeNum.deadline_day,
                              subtaskList: [],
                              attachmentList: [],
                              completed: false
                            )
                          ),
                          TaskWidget(
                            task: TaskVo(
                              id: "00",
                              title: AppLocalizations.of(context)!.walkWithMyDogTitle,
                              description: AppLocalizations.of(context)!.walkWithMyDogDescription,
                              deadline: DateTime(2025, 10, 06),
                              priority: PriorityEnum.low,
                              category: CategoryVo(
                                id: 0,
                                description: '',
                                color: theme.brightness != Brightness.dark
                                  ? darkCategoryColor  
                                  : lightCategoryColor,
                                isDefault: false,
                                activate: true,
                                position: -1
                              ),
                              reminderType: ReminderTypeNum.without_notification,
                              attachmentList: [],
                              subtaskList: [],
                              completed: false
                            ),
                          ),
                          TaskWidget(
                            task: TaskVo(
                              id: "000",
                              title: AppLocalizations.of(context)!.finishMathWorkTile,
                              description: AppLocalizations.of(context)!.finishMathWorkDescription,
                              deadline: DateTime(2025, 05, 02),
                              priority: PriorityEnum.high,
                              category: CategoryVo(
                                id: 0,
                                description: '',
                                color: theme.brightness != Brightness.dark
                                  ? darkCategoryColor
                                  : lightCategoryColor,
                                isDefault: false,
                                activate: true,
                                position: -1
                              ),
                              reminderType: ReminderTypeNum.until_deadline,
                              subtaskList: [],
                              attachmentList: [],
                              completed: false
                            )
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded, size: 40, weight: 200.0),
                  onPressed: () => Navigator.of(context).pop()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded, size: 40, weight: 200.0),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThirdWelcomeScreen()))),
              ),
            ],
          )
        ],
      ),
    );
  }
}
