import 'dart:async';

import 'package:app/core/events/task_events.dart';
import 'package:app/core/utils/translateFailureKey.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/enums/reminder_type_num.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/common/error_snackbar.dart';
import 'package:app/presentation/common/hex_to_color.dart';
import 'package:app/presentation/global_providers/app_preferences_provider.dart';
import 'package:app/presentation/screens/home/category_viewmodel.dart';
import 'package:app/presentation/screens/task_form/task_form_viewmodel.dart';
import 'package:app/services/events/task_event_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskVo? task;

  const TaskFormScreen({this.task, super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  StreamSubscription? _creationSubscription;
  final TaskEventService _taskEventsService = TaskEventService();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dateSelected = DateTime.now();
  CategoryVo? _selectedCategory;
  PriorityEnum _selectedPriority = PriorityEnum.low;
  ReminderTypeNum? _selectedReminderType;

  late AppLocalizations appLocalizations;
  bool _isInit = true;

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final taskFormViewmodel = context.read<TaskFormViewmodel>();

    if (widget.task != null) {
      await taskFormViewmodel.updateTask(
        TaskVo(
          id: "",
          title: _titleController.text,
          description: _descriptionController.text,
          deadline: _dateSelected,
          priority: _selectedPriority,
          category: _selectedCategory!,
          reminderType: _selectedReminderType,
          subtaskList: [],
          attachmentList: [],
          completed: false
        )
      );
      return;
    }

    await taskFormViewmodel.saveTask(
      TaskVo(
        id: "",
        title: _titleController.text,
        description: _descriptionController.text.trim() == "" ? null : _descriptionController.text,
        deadline: _dateSelected,
        priority: _selectedPriority,
        category: _selectedCategory,
        reminderType: _selectedReminderType,
        subtaskList: [],
        attachmentList: [],
        completed: false
      )
    );
  }

  void _loadTaskForUpdate() {
    setState(() {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description!;
      _dateSelected = widget.task!.deadline;
      _selectedPriority = widget.task!.priority;
      _selectedCategory = widget.task!.category;
      _selectedReminderType = widget.task!.reminderType ?? widget.task!.reminderType;
    });
  }

  void _clearFormNewTask() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _dateSelected = DateTime.now();
      _selectedPriority = PriorityEnum.low;
      _selectedCategory = null;
    });
  }

  // TODO traduzir os textos
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateSelected ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: 'Selecione uma data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      appLocalizations = AppLocalizations.of(context)!;
      _isInit = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _creationSubscription = _taskEventsService.onTaskChanged.listen((event) {
            if (event is TaskCreationEvent && event.success) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            }

            if (event is TaskCreationEvent && !event.success) {
              _showSnackBarError(translateFailureKey(appLocalizations, event.failureKey!));
            }

            if (event is TaskUpdateEvent && event.success) {
              _clearFormNewTask();
              if (mounted) {
                Navigator.of(context).pop();
              }
            }

            if (event is TaskUpdateEvent && !event.success) {
              _showSnackBarError(translateFailureKey(appLocalizations, event.failureKey!));
            }
          });
        }

        if (widget.task != null) {
          _loadTaskForUpdate();
        } else {
          _clearFormNewTask();
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
    final taskFormViewmodel = context.watch<TaskFormViewmodel>();
    final categoryViewmodel = context.read<CategoryViewmodel>();

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
                        Icons.check_box_outlined,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 5, offset: Offset(-1, 2.1))],
                        size: 45
                      ),
                      Text(
                        widget.task != null
                          ? AppLocalizations.of(context)!.modifyTask
                          : AppLocalizations.of(context)!.addTask,
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
                                    Icons.alarm_add_rounded,
                                    size: 24,
                                    color: Colors.lightBlue,
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
                            DropdownMenuItem(
                              value: null,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.not_interested_rounded,
                                    size: 24,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    AppLocalizations.of(context)!.withoutReminder,
                                    style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ],
                              )
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedReminderType = value!;
                            });
                          }
                        ),
                        DropdownButtonFormField<dynamic>(
                          value: _selectedCategory,
                          borderRadius: BorderRadius.circular(15),
                          icon: Icon(Icons.dashboard_customize_rounded),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.category,
                          ),
                          items: [
                            ...categoryViewmodel.categories.map((category) {
                              if (!category.isDefault) {
                                return DropdownMenuItem(
                                  value: category,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.dashboard_customize_rounded,
                                        size: 30,
                                        color: hexToColor(category.color),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        category.description,
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return DropdownMenuItem(
                                value: null,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.close_rounded,
                                      size: 30,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      AppLocalizations.of(context)!.withoutCategory,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400
                                      ),
                                    ),
                                  ]
                                )
                              );
                             }
                            ),
                          ],
                          onChanged: (value) {
                           setState(() {
                             _selectedCategory = value;
                           });
                          },
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
        label: taskFormViewmodel.isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text(widget.task != null
              ? AppLocalizations.of(context)!.modifyTask
              : AppLocalizations.of(context)!.addTask,
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


