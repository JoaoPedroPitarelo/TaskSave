import 'dart:async';
import 'package:app/core/events/task_events.dart';
import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/core/utils/translateFailureKey.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/models/attachment_vo.dart';
import 'package:app/domain/models/subtask_vo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/common/error_snackbar.dart';
import 'package:app/presentation/common/hex_to_color.dart';
import 'package:app/presentation/common/subtask_widget.dart';
import 'package:app/presentation/common/sucess_snackbar.dart';
import 'package:app/presentation/global_providers/app_preferences_provider.dart';
import 'package:app/presentation/screens/home/task_viewmodel.dart';
import 'package:app/presentation/screens/task_details/attachment_widget.dart';
import 'package:app/presentation/screens/task_details/task_details_viewmodel.dart';
import 'package:app/services/events/task_event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskVo task;

  const TaskDetailsScreen({required this.task, super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  StreamSubscription? taskSubscription;
  final TaskEventService _taskEventService = TaskEventService();

  late AppLocalizations appLocalizations;
  bool _isInit = true;

  Color _getPriorityColor(BuildContext context, PriorityEnum priority) {
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

  Future<void> _downloadAttachment(AttachmentVo attachment) async {
    final taskDetailsViewModel = context.read<TaskDetailsViewmodel>();
    await taskDetailsViewModel.downloadAttachment(attachment);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      _isInit = false;
      appLocalizations = AppLocalizations.of(context)!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.task.attachmentList.isNotEmpty) {
          for (var attachment in widget.task.attachmentList) {
            _downloadAttachment(attachment);
          }
        }

        taskSubscription = _taskEventService.onTaskChanged.listen((event) {
          if (event is TaskDownloadAttachmentEvent) {
            if (!event.success) {
              _showErrorSnackBar(translateFailureKey(appLocalizations, event.failureKey!));
            }
          }

          if (event is TaskAttachmentSavedAsEvent) {
            if (!event.success) {
              _showErrorSnackBar(appLocalizations.attachmentError);
            } else {
              _showSuccessSnackBar(appLocalizations.attachmentSavedAs);
            }
          }

          if (event is TaskAttachmentDeletedEvent) {
            if (!event.success) {
              _showErrorSnackBar(translateFailureKey(appLocalizations, event.failureKey!));
            }

            if (event.success) {
              _showErrorSnackBar(appLocalizations.attachmentDeleted);
              widget.task.attachmentList.remove(event.attachment);
            }
          }

          if (event is SubtaskDeletionEvent) {
            if (event.success == null) {
              _showUndoSnackbarSubtask(event.task, event.subtask, event.originalIndex);
              return;
            }

            if (!event.success!) {
              _showErrorSnackBar(translateFailureKey(appLocalizations, event.failureKey!));
            }
          }
        });
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      showErrorSnackBar(message)
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      showSuccessSnackBar(message)
    );
  }

  // TODO criar um método geral para isso aqui, com VoidCallbakck
  void _showUndoSnackbarSubtask(TaskVo task, SubtaskVo subtask, int originalIndex) {
    final taskDetailsViewmodel = context.read<TaskDetailsViewmodel>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${AppLocalizations.of(context)!.subtask} ${subtask.title} ${AppLocalizations.of(context)!.deleted}",
          style: GoogleFonts.roboto(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500
          ),
        ),
        elevation: 2,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.undo,
          textColor: Colors.white,
          onPressed: () {
            taskDetailsViewmodel.undoDeletionSubtask(task, subtask, originalIndex);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        showCloseIcon: false,
      ),
    ).closed.then((reason) {
      if (reason != SnackBarClosedReason.action) {
        taskDetailsViewmodel.confirmDeletionSubtask(task, subtask, originalIndex);
      }
    });
  }

  @override
  void dispose() {
    taskSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskDetailsViewModel = context.watch<TaskDetailsViewmodel>();

    final textStyle = GoogleFonts.schibstedGrotesk(
      fontWeight: FontWeight.w400,
      fontSize: 28,
      color: Colors.white,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: widget.task.title, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final textMaxWidth = MediaQuery.of(context).size.width - 20;
    textPainter.layout(maxWidth: textMaxWidth);

    final contentHeight = 100 + textPainter.height + 20;

    double preferredHeight(double contentHeight) {
      if (contentHeight > 200) {
        return contentHeight;
      } else {
        return 110;
      }
    }

    final appColors = AppGlobalColors.of(context);
    final locale = Provider.of<AppPreferencesProvider>(context, listen: false).appLanguage.toString();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(preferredHeight(contentHeight)),
        child: AppBar(
          backgroundColor: _getPriorityColor(context, widget.task.priority),
          elevation: 12,
          shadowColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              )
          ),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.task.title,
                          style: textStyle,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Icon(
                      widget.task.category!.isDefault ? Icons.close_rounded : Icons.dashboard_customize_rounded,
                      size: 35,
                      color: hexToColor(widget.task.category!.color)
                    ),
                    Text(
                      widget.task.category!.isDefault ? AppLocalizations.of(context)!.withoutCategory : widget.task.category!.description,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                      )
                    )
                  ],
                ),
                if (widget.task.deadline != null) ... [
                Row(
                  spacing: 10,
                  children: [
                    Icon(
                        Icons.calendar_month_rounded,
                        size: 35
                    ),
                    Text(
                      intl.DateFormat.yMMMd(locale).format(widget.task.deadline!),
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                      )
                    )
                  ],
                ),
                ],

                // Description
                if (widget.task.description != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: appColors.welcomeScreenCardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Text(
                      widget.task.description!,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                      )
                    ),
                  )
                ),
                Divider(),
                // Attachments
                if (widget.task.attachmentList.isNotEmpty) ...[
                  Row(
                    spacing: 10,
                    children: [
                      Icon(
                        Icons.file_present_rounded,
                        size: 35
                      ),
                      Text(
                        AppLocalizations.of(context)!.attachments,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 23,
                        )
                      )
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: !taskDetailsViewModel.isLoading
                      ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.task.attachmentList.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: AttachmentWidget(
                              attachment: widget.task.attachmentList[i],
                            ),
                          );
                        }
                      )
                      : SizedBox(
                          height: 200,
                          width: 200,
                          child: CircularProgressIndicator()
                      )
                  )
                ],

                // SubTasks
                if (widget.task.subtaskList.isNotEmpty) ... [
                  Row(
                    spacing: 10,
                    children: [
                      Icon(
                        Icons.list,
                        size: 35
                      ),
                      Text(
                        AppLocalizations.of(context)!.subtasks,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 23,
                        )
                      )
                    ],
                  ),
                  ReorderableListView.builder(
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: child,
                        ),
                      );
                    },
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      SubtaskVo subtask = widget.task.subtaskList[i];
                      return SubtaskWidget(
                        key: ValueKey(subtask.id),
                        subtask: subtask,
                        rightDismissedCallback: () async {
                          taskDetailsViewModel.prepareSubtaskForDeletion(widget.task, subtask);
                        },
                        leftDismissedCallback: () => {},
                      );
                    },
                    itemCount: widget.task.subtaskList.length,
                    onReorder: (oldIndex, newIndex) {
                      taskDetailsViewModel.reorderSubtask(widget.task, widget.task.subtaskList[oldIndex], oldIndex, newIndex);
                    }
                  )
                ]
              ]
            ),
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        icon: Icons.add_rounded,
        activeIcon: Icons.close_rounded,
        iconTheme: IconThemeData(size: 30),
        backgroundColor: _getPriorityColor(context, widget.task.priority),
        childrenButtonSize: Size(60, 60),
        childMargin: EdgeInsets.all(20),
        foregroundColor: Colors.white,
        spacing: 20,
        elevation: 8,
        children: [
          SpeedDialChild(
            label: AppLocalizations.of(context)!.delete,
            child:Icon(Icons.close_rounded, color: Colors.red),
            backgroundColor: _getPriorityColor(context, widget.task.priority),
            onTap: () {
              final taskViewmodel = context.read<TaskViewmodel>();
              taskViewmodel.prepareTaskForDeletion(widget.task);
              Navigator.of(context).pop();
            }
          ),
          SpeedDialChild(
            label: AppLocalizations.of(context)!.addSubTask,
            child:Icon(Icons.list_rounded),
            backgroundColor: _getPriorityColor(context, widget.task.priority),
            onTap: () {
              // TODO quando estiver pontor a tela de criação de subtarefa
            }
          ),
          SpeedDialChild(
            label: AppLocalizations.of(context)!.addAttachment,
            child:Icon(Icons.file_upload_rounded),
            backgroundColor: _getPriorityColor(context, widget.task.priority),
            onTap: () {
              // TODO fazer tela ou alertDialog de adição de anexos
            }
          ),
          SpeedDialChild(
              label: AppLocalizations.of(context)!.edit,
              child: Icon(Icons.edit_rounded),
              backgroundColor: _getPriorityColor(context, widget.task.priority),
              onTap: () {
                // TODO quando estiver pronto a tela de edição
              }
          ),
        ]
      )
    );
  }
}
