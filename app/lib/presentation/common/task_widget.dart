import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/domain/enums/reminder_type_num.dart';
import 'package:app/domain/models/attachmentVo.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/models/subtask_vo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/presentation/screens/task_details/task_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

class TaskWidget extends StatefulWidget {
  final TaskVo task;
  VoidCallback? onDismissedCallback;

  TaskWidget({
    super.key,
    required this.task,
    this.onDismissedCallback
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
    
    return Dismissible(
      key: Key(widget.task.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) async {

        await player.play(AssetSource("sounds/taskCompleted.mp3"));
        widget.task.completed = true;

        if (widget.onDismissedCallback != null) {
          widget.onDismissedCallback!();
        }
      },
      background: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
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
      child: Stack(
        children: [
          if (widget.task.subtaskList.isNotEmpty) ...[
            Positioned(
              bottom: 4,
              left: 16,
              right: 16,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: appColors.taskCardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 24,
              right: 24,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: appColors.taskCardColor?.withAlpha(125),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
          GestureDetector(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: widget.task))
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8.0, top: 8.0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 30,
                      decoration: BoxDecoration(
                          color: getPriorityColor(context, widget.task.priority),
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
                                  BorderRadius.only(topRight: Radius.circular(20)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.task.title, style: theme.textTheme.labelMedium),
                                  SizedBox(height: 8),
                                  Container(
                                    height: 28,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      color: appColors.taskFooterColor),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.date_range, size: 18),
                                          SizedBox(width: 4),
                                          Text(DateFormat('dd/MM/yyyy').format(widget.task.deadline), style: theme.textTheme.displaySmall),
                                          if (widget.task.reminderType != null) ...[
                                            SizedBox(width: 8),
                                            Icon(Icons.alarm, size: 18),
                                          ],
                                          if (widget.task.attachmentList.isNotEmpty) ...[
                                            SizedBox(width: 8),
                                            Icon(Icons.file_present_outlined, size: 18),
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: appColors.taskFooterColor,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 0.1,
                                  offset: Offset(0.1, 0)
                                )
                              ]
                            ),
                            padding: EdgeInsets.all(9),
                            child: Text(
                              widget.task.description ?? "",
                              style: theme.textTheme.displaySmall,
                              textAlign: TextAlign.start,
                            ),
                          ),
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
}
