import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:task_save/core/events/task_events.dart';
import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/core/utils/translateFailureKey.dart';
import 'package:task_save/domain/enums/priority_enum.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/subtask_vo.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/common/error_snackbar.dart';
import 'package:task_save/presentation/common/hex_to_color.dart';
import 'package:task_save/presentation/common/subtask_widget.dart';
import 'package:task_save/presentation/common/sucess_snackbar.dart';
import 'package:task_save/presentation/global_providers/app_preferences_provider.dart';
import 'package:task_save/presentation/screens/home/task_viewmodel.dart';
import 'package:task_save/presentation/screens/subtask_form/subtask_form_screen.dart';
import 'package:task_save/presentation/screens/task_details/attachment_widget.dart';
import 'package:task_save/presentation/screens/task_details/task_details_viewmodel.dart';
import 'package:task_save/presentation/screens/task_form/task_form_screen.dart';
import 'package:task_save/services/events/task_event_service.dart';
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

  List<SubtaskVo>? _subtaskList = [];

  Color _getPriorityColor(PriorityEnum priority) {
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

  String getTranslatedPriority(PriorityEnum priority) {
    switch (priority) {
      case PriorityEnum.low:
        return AppLocalizations.of(context)!.low;
      case PriorityEnum.medium:
        return AppLocalizations.of(context)!.medium;
      case PriorityEnum.high:
        return AppLocalizations.of(context)!.high;
      case PriorityEnum.neutral:
        return AppLocalizations.of(context)!.neutral;
    }
  }

  String getTranslatedReminderType(ReminderTypeNum reminderType) {
    switch (reminderType) {
      case ReminderTypeNum.before_deadline:
        return AppLocalizations.of(context)!.beforeDeadline;
      case ReminderTypeNum.deadline_day:
        return AppLocalizations.of(context)!.deadlineDay;
      case ReminderTypeNum.until_deadline:
        return AppLocalizations.of(context)!.untilDeadline;
      case ReminderTypeNum.without_notification:
        return AppLocalizations.of(context)!.withoutReminder;
    }
  }


  Future<void> _initAttachments() async {
    final taskDetailsViewModel = context.read<TaskDetailsViewmodel>();
    await taskDetailsViewModel.initializeAttachmentsStatus(widget.task);
  }

  void _initSubtasks() {
    final taskDetailsViewModel = context.read<TaskDetailsViewmodel>();
    taskDetailsViewModel.initializeSubtaskList(widget.task.subtaskList);
  }

  @override
  void initState() {
    super.initState();

    _initAttachments();
    _initSubtasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      _isInit = false;
      appLocalizations = AppLocalizations.of(context)!;

      final taskDetailsViewmodel = context.read<TaskDetailsViewmodel>();

      WidgetsBinding.instance.addPostFrameCallback((_) {
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

          if (event is TaskAttachmentUploadEvent) {
            if (!event.success) {
              _showErrorSnackBar(translateFailureKey(appLocalizations, event.failureKey!));
            } else {
              _initAttachments();
              _showSuccessSnackBar("Anexo enviado com sucesso!");
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

          if(event is SubtaskCreationEvent) {
            if (!event.success) {
              _showErrorSnackBar(translateFailureKey(appLocalizations, event.failureKey!));
            } else {
              taskDetailsViewmodel.addSubtask(event.subtask!);
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
        taskDetailsViewmodel.confirmSubtaskDeletion(task, subtask, originalIndex);
      }
    });
  }

  Future<void> _showAddAttachmentDialog() async {
    final taskDetailsViewModel = context.read<TaskDetailsViewmodel>();
    File? selectedFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 24, 24, 24),
              title: Row(
                children: [
                  Icon(
                    Icons.file_present_rounded,
                    size: 40,
                  ),
                  SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.addAttachment),
                ],
              ),
              content: selectedFile == null
                  ? Text(AppLocalizations.of(context)!.selectAFileToUpload)
                  : Text("${AppLocalizations.of(context)!.file}: ${selectedFile!.path.split(Platform.pathSeparator).last}"),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Row(
                        children: [
                          Icon(Icons.close_rounded, color: Colors.red, size: 30),
                          Text(
                            AppLocalizations.of(context)!.cancel,
                            style: GoogleFonts.roboto(fontSize: 16, color: Colors.white)
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    if (selectedFile == null)
                      TextButton(
                        child: Row(
                          children: [
                            Icon(Icons.file_upload_rounded, color: Colors.green, size: 30),
                            Text(
                              AppLocalizations.of(context)!.selectFile,
                              style: GoogleFonts.roboto(fontSize: 16, color: Colors.white)
                            ),
                          ],
                        ),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if (result != null) {
                            setState(() {
                              selectedFile = File(result.files.single.path!);
                            });
                          }
                        },
                      )
                    else
                      TextButton(
                        child: Row(
                          children: [
                            Icon(Icons.check_rounded, color: Colors.green, size: 30),
                            SizedBox(width: 10),
                            Text(AppLocalizations.of(context)!.confirm, style: GoogleFonts.roboto(fontSize: 16, color: Colors.white)),
                          ],
                        ),
                        onPressed: () async {
                          if (selectedFile != null) {
                            await taskDetailsViewModel.uploadAttachment(selectedFile!, widget.task);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ),
                  ],
                )
              ]
            );
          },
        );
      },
    );
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
          backgroundColor: _getPriorityColor(widget.task.priority),
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
                      Icons.flag_rounded,
                      color: _getPriorityColor(widget.task.priority),
                      size: 35,
                    ),
                    Text(
                        "${AppLocalizations.of(context)!.priority} ${getTranslatedPriority(widget.task.priority).toLowerCase()}",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 23,
                        )
                    )
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    Icon(
                      widget.task.category!.isDefault ? Icons.close_rounded : Icons.dashboard_customize_rounded,
                      size: 35,
                      color: widget.task.category!.isDefault ? Colors.red : hexToColor(widget.task.category!.color)
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
                Row(
                  spacing: 10,
                  children: [
                    Icon(
                      widget.task.reminderType == ReminderTypeNum.without_notification ? Icons.alarm_off_rounded : Icons.access_alarm_rounded,
                      size: 35,
                    ),
                    Text(
                      getTranslatedReminderType(widget.task.reminderType!),
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
                  if (taskDetailsViewModel.isLoading) ... [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: CircularProgressIndicator(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          strokeAlign: 5,
                          strokeWidth: 5,
                        ),
                      ),
                    )
                  ] else ... [
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.task.attachmentList.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: AttachmentWidget(
                              attachment: widget.task.attachmentList[i],
                              status: taskDetailsViewModel.attachmentStatus[widget.task.attachmentList[i].id]!,
                            ),
                          );
                        }
                      )
                    )
                  ]
                ],
                // SubTasks
                if (taskDetailsViewModel.subtaskList.isNotEmpty) ... [
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
                      SubtaskVo subtask = taskDetailsViewModel.subtaskList[i];
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
        backgroundColor: _getPriorityColor(widget.task.priority),
        childrenButtonSize: Size(60, 60),
        childMargin: EdgeInsets.all(20),
        foregroundColor: Colors.white,
        spacing: 20,
        elevation: 8,
        children: [
          SpeedDialChild(
            label: AppLocalizations.of(context)!.delete,
            child:Icon(Icons.delete_outline_rounded, color: Colors.white),
            backgroundColor: _getPriorityColor(widget.task.priority),
            onTap: () {
              final taskViewmodel = context.read<TaskViewmodel>();
              taskViewmodel.prepareTaskForDeletion(widget.task);
              Navigator.of(context).pop();
            }
          ),
          SpeedDialChild(
            label: AppLocalizations.of(context)!.addSubTask,
            child:Icon(Icons.list_rounded),
            backgroundColor: _getPriorityColor(widget.task.priority),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SubtaskFormScreen(task: widget.task))
              );
            }
          ),
          SpeedDialChild(
            label: AppLocalizations.of(context)!.addAttachment,
            child:Icon(Icons.file_upload_rounded),
            backgroundColor: _getPriorityColor(widget.task.priority),
            onTap: _showAddAttachmentDialog,
          ),
          SpeedDialChild(
            label: AppLocalizations.of(context)!.edit,
            child: Icon(Icons.edit_rounded),
            backgroundColor: _getPriorityColor(widget.task.priority),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TaskFormScreen(task: widget.task))
              );
            }
          ),
        ]
      )
    );
  }
}
