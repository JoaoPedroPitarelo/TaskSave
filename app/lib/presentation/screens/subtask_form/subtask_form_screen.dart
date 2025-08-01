import 'dart:async';
import 'package:task_save/core/events/task_events.dart';
import 'package:task_save/domain/enums/priority_enum.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/subtask_vo.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/common/error_snackbar.dart';
import 'package:task_save/presentation/global_providers/app_preferences_provider.dart';
import 'package:task_save/presentation/screens/subtask_form/subtask_form_viewmodel.dart';
import 'package:task_save/services/events/task_event_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SubtaskFormScreen extends StatefulWidget {
  final SubtaskVo? subtask;
  final TaskVo task;

  const SubtaskFormScreen({this.subtask, required this.task, super.key});

  @override
  State<SubtaskFormScreen> createState() => _SubtaskFormScreenState();
}

class _SubtaskFormScreenState extends State<SubtaskFormScreen> {
  StreamSubscription? _creationSubscription;
  final TaskEventService _taskEventsService = TaskEventService();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dateSelected = DateTime.now();
  PriorityEnum _selectedPriority = PriorityEnum.low;
  ReminderTypeNum? _selectedReminderType = ReminderTypeNum.without_notification;

  late AppLocalizations appLocalizations;
  bool _isInit = true;

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final subtaskFormViewmodel = context.read<SubtaskFormViewmodel>();

    if (widget.subtask != null) {
      await subtaskFormViewmodel.updateSubtask(
        SubtaskVo(
          id: widget.subtask!.id,
          title: _titleController.text,
          description: _descriptionController.text.trim() == "" ? "" : _descriptionController.text,
          deadline: _dateSelected,
          priority: _selectedPriority,
          reminderType: _selectedReminderType,
          completed: false
        )
      );
      return;
    }

    await subtaskFormViewmodel.saveSubtask(
      SubtaskVo(
        id: "",
        title: _titleController.text,
        description: _descriptionController.text.trim() == "" ? null : _descriptionController.text,
        deadline: _dateSelected,
        priority: _selectedPriority,
        reminderType: _selectedReminderType,
        completed: false
      ),
      widget.task
    );
  }

  void _loadSubtaskForUpdate() {
    setState(() {
      _titleController.text = widget.subtask!.title;
      _descriptionController.text = widget.subtask!.description == null ? "" : widget.subtask!.description!;
      _dateSelected = widget.subtask!.deadline;
      _selectedPriority = widget.subtask!.priority;
      _selectedReminderType = widget.subtask!.reminderType ?? widget.subtask!.reminderType;
    });
  }

  void _clearFormNewSubtask() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _dateSelected = DateTime.now();
      _selectedPriority = PriorityEnum.low;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateSelected ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: AppLocalizations.of(context)!.selectDate,
      cancelText: AppLocalizations.of(context)!.cancel,
      confirmText: AppLocalizations.of(context)!.confirm,
    );
    if (picked != null && picked != _dateSelected) {
      setState(() {
        _dateSelected = picked;
      });
    }
  }

  void _showSnackBarError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      showErrorSnackBar(message)
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.subtask != null) {
      _loadSubtaskForUpdate();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      appLocalizations = AppLocalizations.of(context)!;
      _isInit = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _creationSubscription = _taskEventsService.onTaskChanged.listen((event) {
            if (event is SubtaskCreationEvent && event.success) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _creationSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final subtaskFormViewmodel = context.watch<SubtaskFormViewmodel>();

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

    Color getPriorityColor(PriorityEnum priority) {
      switch (priority) {
        case PriorityEnum.low:
          return Color.fromARGB(255, 15, 201, 63);
        case PriorityEnum.medium:
          return Color.fromARGB(255, 255, 106, 18);
        case PriorityEnum.high:
          return Color.fromARGB(255, 206, 8, 8);
        case PriorityEnum.neutral:
          return Color.fromARGB(255, 33, 198, 243);
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

    final locale = Provider.of<AppPreferencesProvider>(context, listen: false).appLanguage.toString();
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(115),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 12, 43, 170),
          elevation: 12,
          shadowColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white, size: 30),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            )
          ),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_rounded,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 5, offset: Offset(-1, 2.1))],
                        size: 45
                      ),
                      Text(
                        widget.subtask != null
                          ? AppLocalizations.of(context)!.modifySubtask
                          : AppLocalizations.of(context)!.addSubTask,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w400
                        )
                      )
                    ]
                  ),
                ],
              ),
            )
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom
            ),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.drive_file_rename_outline_rounded),
                            fillColor: const Color.fromARGB(31, 175, 175, 175),
                            labelText: AppLocalizations.of(context)!.labelTextTitleTaskForm,
                            hintText: AppLocalizations.of(context)!.hintTextTitleTaskForm,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14
                            ),
                          ),
                          maxLength: 50,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.taskTitleIsObrigatory;
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description_rounded),
                            fillColor: const Color.fromARGB(31, 175, 175, 175),
                            labelText: AppLocalizations.of(context)!.labelTextDescriptionTaskForm,
                            hintText: AppLocalizations.of(context)!.hintTextDescriptionTaskForm,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14
                            ),
                          ),
                          maxLength: 255,
                          maxLines: 3,
                        ),
                        GestureDetector(
                          onTap: () => _selectDate(),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                style: BorderStyle.solid,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, size: 30),
                                  SizedBox(width: 10),
                                  Text(
                                    '${AppLocalizations.of(context)!.deadline}: ',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400
                                    ),
                                  ),
                                  Text(
                                    _dateSelected != null ? DateFormat.yMMMd(locale).format(_dateSelected!) : '',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),

                        DropdownButtonFormField<PriorityEnum>(
                          value: _selectedPriority,
                          borderRadius: BorderRadius.circular(15),
                          icon: Icon(Icons.flag_rounded),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.priority,
                          ),
                          items: PriorityEnum.values.map((priority) => DropdownMenuItem(
                            value: priority,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(
                                Icons.flag_rounded,
                                  size: 30,
                                  color: getPriorityColor(priority),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  getTranslatedPriority(priority),
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400
                                  ),
                                ),
                              ]),
                            ),
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return AppLocalizations.of(context)!.priorityIsObrigatory;
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<ReminderTypeNum>(
                          value: _selectedReminderType,
                          borderRadius: BorderRadius.circular(15),
                          icon: Icon(Icons.notifications_active_rounded),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.reminderType,
                          ),
                          items: [
                            ...ReminderTypeNum.values.map((reminderType) => DropdownMenuItem(
                              value: reminderType,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    reminderType == ReminderTypeNum.without_notification ?  Icons.alarm_off_rounded  : Icons.alarm_add_rounded,
                                    size: 24,
                                    color:  reminderType == ReminderTypeNum.without_notification ? Colors.red : Colors.lightBlue,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    getTranslatedReminderType(reminderType),
                                    style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedReminderType = value;
                            });
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        )
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _submitForm(context);
        },
        label: subtaskFormViewmodel.isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text(widget.subtask != null
              ? AppLocalizations.of(context)!.modifySubtask
              : AppLocalizations.of(context)!.addSubTask,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w400
            ),
        ),
        icon: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 35
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


