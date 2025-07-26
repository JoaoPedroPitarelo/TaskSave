import 'dart:async';
import 'package:app/core/events/task_events.dart';
import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/core/utils/translateFailureKey.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/models/attachmentVo.dart';
import 'package:app/domain/models/subtask_vo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/common/error_snackbar.dart';
import 'package:app/presentation/common/hex_to_color.dart';
import 'package:app/presentation/common/subtask_widget.dart';
import 'package:app/presentation/common/sucess_snackbar.dart';
import 'package:app/presentation/screens/home/home_viewmodel.dart';
import 'package:app/presentation/screens/home/task_viewmodel.dart';
import 'package:app/presentation/screens/task_details/attachment_widget.dart';
import 'package:app/presentation/screens/task_details/task_details_viewmodel.dart';
import 'package:app/services/events/task_event_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.task.attachmentList.isNotEmpty) {
        for (var attachment in widget.task.attachmentList) {
          _downloadAttachment(attachment);
        }
      }

      taskSubscription = _taskEventService.onTaskChanged.listen((event) {
        if (event is TaskDownloadAttachmentEvent) {
          if (!event.success) {
            _showErrorSnackBar(translateFailureKey(context, event.failureKey!));
          }
        }

        if (event is TaskAttachmentSavedAsEvent) {
          if (!event.success) {
            _showErrorSnackBar(AppLocalizations.of(context)!.attachmentError);
          } else {
            _showSuccessSnackBar(AppLocalizations.of(context)!.attachmentSavedAs);
          }
        }

        if (event is TaskAttachmentDeletedEvent) {
          if (!event.success) {
            _showErrorSnackBar(translateFailureKey(context, event.failureKey!));
          }

          if (event.success) {
            _showErrorSnackBar(AppLocalizations.of(context)!.attachmentDeleted);
            widget.task.attachmentList.remove(event.attachment);
          }
        }

        if (event is SubtaskDeletionEvent) {
          if (event.success == null) {
            _showUndoSnackbarSubtask(event.task, event.subtask, event.originalIndex);
            return;
          }

          if (!event.success!) {
            _showErrorSnackBar(translateFailureKey(context, event.failureKey!));
          }
        }
      });
    });

    super.initState();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      showErrorSnackbar(message)
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      showSuccessSnackbar(message)
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
          actions: [
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: _getPriorityColor(context, widget.task.priority),
              onSelected: (value) {
                if (value == "edit") {
                  // TODO quando estiver pronto a tela de edição
                }
                if (value == "delete") {
                  final taskViewmodel = context.read<TaskViewmodel>();
                  taskViewmodel.prepareTaskForDeletion(widget.task);

                  Navigator.of(context).pop();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: "edit",
                  child: Row(
                    spacing: 10,
                    children: [
                      const Icon(Icons.edit, size: 25),
                      Text(
                        AppLocalizations.of(context)!.edit,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: "delete",
                  child: Row(
                    spacing: 10,
                    children: [
                      const Icon(Icons.close_rounded, size: 25),
                      Text(
                        AppLocalizations.of(context)!.delete,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ]
            )
          ],
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
                if (widget.task.category.description != "Default")
                Row(
                  spacing: 10,
                  children: [
                    Icon(
                      Icons.dashboard_customize_outlined,
                      size: 35,
                      color: hexToColor(widget.task.category.color)
                    ),
                    Text(
                      widget.task.category.description,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                      )
                    )
                  ],
                ),

                // Description
                if (widget.task.description != null)
                Container(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO criar método de criação de subtarefas
        },
        backgroundColor:  _getPriorityColor(context, widget.task.priority),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30,
        ),
      )
    );
  }
}
