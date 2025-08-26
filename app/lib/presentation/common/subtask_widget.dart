import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/domain/enums/priority_enum.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/subtask_vo.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:task_save/presentation/global_providers/app_preferences_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;

class SubtaskWidget extends StatefulWidget {
  final SubtaskVo subtask;
  final VoidCallback? rightDismissedCallback;
  final VoidCallback? leftDismissedCallback;

  const SubtaskWidget({
    super.key,
    required this.subtask,
    this.rightDismissedCallback,
    this.leftDismissedCallback
  });

  @override
  State<SubtaskWidget> createState() => _SubtaskWidgetState();
}

class _SubtaskWidgetState extends State<SubtaskWidget> {
  final player = AudioPlayer();

  Color getPriorityColor(BuildContext context, PriorityEnum priority) {
    final appColor = AppGlobalColors.of(context);
    switch (priority) {
      case PriorityEnum.neutral:
        return appColor.taskPriorityNeutralColor!;
      case PriorityEnum.low:
        return appColor.taskPriorityLowColor!;
      case PriorityEnum.medium:
        return appColor.taskPriorityMediumColor!;
      case PriorityEnum.high:
        return appColor.taskPriorityHighColor!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);
    final locale = Provider.of<AppPreferencesProvider>(context, listen: false).appLanguage.toString();

    return Dismissible(
      key: Key(widget.subtask.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          if (widget.leftDismissedCallback != null) {
            widget.leftDismissedCallback!();
          }
          return false;
        }
        return true;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          if (widget.rightDismissedCallback != null) {
            widget.rightDismissedCallback!();
          }
          player.play(AssetSource("sounds/taskCompleted.mp3"));
          widget.subtask.completed = true;
        }
      },
      background: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: const Color.fromARGB(255, 0, 255, 8),
              size: 80,
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.edit_rounded,
              color: Colors.blue,
              size: 70,
            ),
          ]
        ),
      ),
      child: Stack(
        children: [
          GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8.0, top: 8.0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 30,
                      decoration: BoxDecoration(
                        color: getPriorityColor(context, widget.subtask.priority),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10)
                        )
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: appColors.taskCardColor,
                              borderRadius:
                              BorderRadius.only(
                                topRight: Radius.circular(10), 
                                bottomRight: widget.subtask.description != null && widget.subtask.description!.isNotEmpty
                                    ? Radius.circular(0)
                                    : Radius.circular(10)
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.subtask.title, style: theme.textTheme.labelMedium),
                                  SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: appColors.taskFooterColor!.withAlpha(130),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: appColors.taskFooterColor!.withAlpha(50)
                                      )
                                    ),
                                    height: 28,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (widget.subtask.deadline != null) ...[
                                            Icon(Icons.date_range_rounded, size: 18),
                                            SizedBox(width: 4),
                                            Text(intl.DateFormat.yMMMd(locale).format(widget.subtask.deadline!), style: theme.textTheme.displaySmall),
                                          ],
                                          if (widget.subtask.reminderType != null && widget.subtask.reminderType != ReminderTypeNum.without_notification) ...[
                                            SizedBox(width: 8),
                                            Icon(Icons.alarm_rounded, size: 18),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.subtask.description != null && widget.subtask.description != "") ... [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: appColors.taskFooterColor,
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              padding: EdgeInsets.all(9),
                              child: Text(
                                formatDescription(widget.subtask.description),
                                style: theme.textTheme.displaySmall,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDescription(String? description) {
    if (description == null) {
      return "";
    }

    if (description.length > 150) {
      return "${description.substring(0, 150)}...";
    }

    return description;
  }

  String formatTitle(String title) {
    if (title.length > 28) {
      return "${title.substring(0, 28)}...";
    }
    return title;
  }
}
