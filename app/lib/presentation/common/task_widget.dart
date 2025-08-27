import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/domain/enums/priority_enum.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/presentation/common/hex_to_color.dart';
import 'package:task_save/presentation/screens/task_details/task_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:task_save/presentation/global_providers/app_preferences_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;

class TaskWidget extends StatefulWidget {
  final TaskVo task;
  final VoidCallback? rightDismissedCallback;
  final VoidCallback? leftDismissedCallback;

  const TaskWidget({
    super.key,
    required this.task,
    this.rightDismissedCallback,
    this.leftDismissedCallback
  });

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
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
      key: Key(widget.task.id),
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
          widget.task.completed = true;
        }
      },
      background: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.check_box_outlined,
              color: const Color.fromARGB(255, 51, 176, 38),
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
              color: const Color.fromARGB(255, 39, 135, 212),
              size: 70,
            ),
          ]
        ),
      ),
      child: Stack(
        children: [
          if (widget.task.subtaskList.isNotEmpty) ...[
            Positioned(
              bottom: 4,
              left: 6,
              right: 6,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                    ? appColors.taskCardColor
                    : Colors.grey.withAlpha(210) ,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 12,
              right: 12,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                    ? appColors.taskCardColor?.withAlpha(100)
                    : Colors.grey.withAlpha(150),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          GestureDetector(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: widget.task))
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 35,
                      decoration: BoxDecoration(
                        color: getPriorityColor(context, widget.task.priority),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
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
                                  bottomRight: widget.task.description != null && widget.task.description!.isNotEmpty
                                    ? Radius.circular(0)
                                    : Radius.circular(10)
                                ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formatTitle(widget.task.title), style: theme.textTheme.labelMedium),
                                  SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: appColors.taskFooterColor!,
                                      borderRadius: BorderRadius.circular(8),
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
                                          if (widget.task.deadline != null) ... [
                                            Icon(Icons.date_range_rounded, size: 18),
                                            SizedBox(width: 4),
                                            Text(intl.DateFormat.yMMMd(locale).format(widget.task.deadline!), style: theme.textTheme.displaySmall),
                                          ],
                                          if (widget.task.reminderType != null && widget.task.reminderType != ReminderTypeNum.without_notification) ...[
                                            SizedBox(width: 8),
                                            Icon(Icons.alarm, size: 18),
                                          ],
                                          if (widget.task.attachmentList.isNotEmpty) ...[
                                            SizedBox(width: 8),
                                            Icon(Icons.file_present_outlined, size: 18),
                                          ],
                                          if (widget.task.category != null && !widget.task.category!.isDefault) ...[
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.dashboard_rounded, 
                                              color: hexToColor(widget.task.category!.color),
                                              size: 18
                                            ),
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.task.description != null && widget.task.description != "") ... [
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
                                formatDescription(widget.task.description),
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
