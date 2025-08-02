import 'dart:convert';
import 'dart:io';
import 'package:task_save/core/enums/filtering_task_mode_enum.dart';
import 'package:task_save/core/enums/task_type_enum.dart';
import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/core/errors/failure_keys.dart';
import 'package:task_save/core/events/task_events.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/notifiable.dart';
import 'package:task_save/domain/models/subtask_vo.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/global_providers/app_preferences_provider.dart';
import 'package:task_save/repositories/api/task_repository.dart';
import 'package:task_save/services/events/task_event_service.dart';
import 'package:task_save/services/notifications/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:task_save/core/utils/date_utils.dart';
import 'package:provider/provider.dart';
import 'category_viewmodel.dart';

class TaskViewmodel extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final CategoryViewmodel _categoryViewmodel;
  final NotificationService _notificationService;
  final TaskEventService _taskEventService = TaskEventService();

  final FailureKey Function(Failure) _mapFailureToKey;
  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  List<dynamic> _tasks = [];
  List<dynamic> get tasks => _tasks;

  List<dynamic> _filteredTasks = [];
  List<dynamic> get filteredTasks => _filteredTasks;

  FilteringTaskModeEnum _filterMode = FilteringTaskModeEnum.all;
  FilteringTaskModeEnum get filterMode => _filterMode;

  int _countAllTasks = 0;
  int _countTodayTasks = 0;
  int _countNextWeekTasks = 0;
  int _countNextMonthTasks = 0;
  int _overdueTasks = 0;

  String _searchQuery = '';

  int get countAllTasks => _countAllTasks;
  int get countTodayTasks => _countTodayTasks;
  int get countNextWeekTasks => _countNextWeekTasks;
  int get countNextMonthTasks => _countNextMonthTasks;
  int get countOverdueTasks => _overdueTasks;

  bool _loading = false;
  bool get loading => _loading;

  TaskViewmodel(
    this._taskRepository,
    this._notificationService,
    this._mapFailureToKey,
    this._categoryViewmodel
  ) {
    _categoryViewmodel.addListener(_onFilterOrCategoryChanged);
  }

  void _onFilterOrCategoryChanged() {
    if (_filterMode == FilteringTaskModeEnum.category) {
      filterTasks(_filterMode);
    }
    if (_categoryViewmodel.deletedSelectedCategory != null && _filterMode == FilteringTaskModeEnum.category) {
      clearAllFiltersForTasks();
    }
  }

  @override
  void dispose() {
    _categoryViewmodel.removeListener(_onFilterOrCategoryChanged);
    super.dispose();
  }

  Future<void> getTasks() async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _taskRepository.getAll();

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _taskEventService.add(GetTasksEvent(success: false, failureKey: _errorKey));
        _loading = false;
        notifyListeners();
      },
      (tasks) {
        _tasks = tasks['tasks'].map((task) => TaskVo.fromJson(task)).toList();
        _filteredTasks = _tasks;
        _calculateCountTasks();
        filterTasks(_filterMode);
        _loading = false;
        notifyListeners();
      }
    );
  }

  Future<void> scheduleNotifications(List<dynamic> tasks, BuildContext context) async {
    if (!context.mounted) return;
    final locale = Provider.of<AppPreferencesProvider>(context, listen: false).appLanguage.toString(); // para a tradução de Datetime usado no DateFormat
    final localizations = AppLocalizations.of(context)!; // para a tradução das frases da notificação

    for (final task in tasks) {
      if ((task.subtaskList as List).isNotEmpty) {
        for (final subtask in task.subtaskList) {
          if (!isTaskNotifiable(subtask)) {
            continue;
          }

          if (await _isThisTaskScheduledForNotification(subtask, TaskType.st)) {
            continue;
          }

          _scheduleSubtaskNotification(subtask, localizations, locale);
        }
      }

      if (!isTaskNotifiable(task)) {
        continue;
      }

      if (await _isThisTaskScheduledForNotification(task, TaskType.t)) {
        continue;
      }

      _scheduleTaskNotification(task, localizations, locale);
    }
  }

  bool isTaskNotifiable(Notifiable notifiable) {
    return notifiable.reminderType != null  && notifiable.reminderType != ReminderTypeNum.without_notification && notifiable.deadline != null;
  }

  Future<void> _scheduleTaskNotification(TaskVo task, AppLocalizations localizations, String locale) async {
    final scheduledTimes = _calculateScheduledTimes(task);

    for (int i = 0; i < scheduledTimes.length; i++) {
      final scheduledTime = scheduledTimes[i];
      final notificationId = int.parse(task.id) * 1000 + i;

      String dateFormated = DateFormat.yMMMd(locale).format(task.deadline!);

      _notificationService.scheduleNotification(
        notificationId,
        "${localizations.task}: ${task.title}",
        "${localizations.yourTask} $dateFormated ${localizations.expiredTask} ${localizations.clickToShowDetailsTask}",
        scheduledTime,
        '{"id": "${task.id}", "taskType": "${TaskType.t.name}"}'
      );

      print('Scheduled notification for task ${task.title} at $scheduledTime');
    }
  }

  void _scheduleSubtaskNotification(SubtaskVo subtask, AppLocalizations localizations, String locale) {
    final scheduledTimes = _calculateScheduledTimes(subtask);

    for(int i = 0; i < scheduledTimes.length; i++) {
      final scheduledTime = scheduledTimes[i];
      final notificationId = int.parse(subtask.id) * 1000 + i;

      String dateFormated = DateFormat.yMMMd(locale).format(subtask.deadline!);

      _notificationService.scheduleNotification(
        notificationId,
        "${localizations.subtask}: ${subtask.title}",
        "${localizations.yourSubtask} $dateFormated ${localizations.expiredTask} ${localizations.clickToShowDetailsTask}",
        scheduledTime,
        '{"id": "${subtask.id}", "taskType": "${TaskType.st.name}"}'
      );

      print('Scheduled notification for subtask ${subtask.title} at $scheduledTime');
    }
  }

  Future<bool> _isThisTaskScheduledForNotification(Notifiable task, TaskType taskType) async {
    final List<PendingNotificationRequest> pendingNotifications = await _notificationService.getPendingNotifications();

    for (final notification in pendingNotifications) {
      Map<String, dynamic> notificationPayload = jsonDecode(notification.payload!);
      print(notificationPayload);
      TaskType notificationTaskType = TaskType.values.firstWhere((type) => type.name == notificationPayload['taskType']);

      if (notificationTaskType.name == taskType.name) {
        if (notificationPayload['id'] == task.id.toString()) {
          return true;
        }
      }
    }
    return false;
  }

  List<DateTime> _calculateScheduledTimes(Notifiable notifiable) {
    final now = DateTime.now();
    final deadline = notifiable.deadline;
    List<DateTime> scheduledTimes = [];

    switch (notifiable.reminderType) {
      case ReminderTypeNum.before_deadline:
        final scheduledDay = deadline!.subtract(const Duration(days: 1));
        final scheduledTime = DateTime(scheduledDay.year, scheduledDay.month, scheduledDay.day, 10, 0);

        if (scheduledTime.isAfter(now)) {
          scheduledTimes.add(scheduledTime);
        }
        break;
      case ReminderTypeNum.deadline_day:
        final scheduledTime = DateTime(deadline!.year, deadline.month, deadline.day, 10, 0);

        if (scheduledTime.isAfter(now)) {
          scheduledTimes.add(scheduledTime);
        }
        break;
      case ReminderTypeNum.until_deadline:
        for (var day = now; day.isBefore(deadline!.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
          final scheduledTime = DateTime(day.year, day.month, day.day, 10, 0);

          if (scheduledTime.isAfter(now)) {
            scheduledTimes.add(scheduledTime);
          }
        }
        break;
      default:
        break;
    }
    return scheduledTimes;
  }

  void prepareTaskForDeletion(TaskVo task) {
    final originalIndex = _filteredTasks.indexOf(task);
    if (originalIndex == -1)  return;

    _filteredTasks.removeAt(originalIndex);

    _taskEventService.add(TaskDeletionEvent(task, originalIndex));
    notifyListeners();
  }

  void undoDeletionTask(TaskVo task, int originalIndex) {
    if(!_filteredTasks.contains(task)) {
      _filteredTasks.insert(originalIndex.clamp(0, _filteredTasks.length), task);
      notifyListeners();
    }
  }

  Future<void> confirmTaskDeletion(TaskVo task, originalIndex) async {
    final result = await _taskRepository.delete(task);

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        undoDeletionTask(task, originalIndex);
        _loading = false;
        notifyListeners();
      },
      (noContent) {
        _tasks.remove(task);
        _calculateCountTasks();
        _notificationService.cancelNotificationsByPayload('{"id": "${task.id}", "taskType": "${TaskType.t.name}"}');
        notifyListeners();
      }
    );
  }

  Future<void> exportToPDF(String? categoryId) async {
    _loading = true;
    notifyListeners();

    final result = await _taskRepository.exportTasksToPDF(categoryId);

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _taskEventService.add(TaskExportPDFEvent(success: false, failureKey: _errorKey));
        _loading = false;
        notifyListeners();
      },
      (file) {
        _taskEventService.add(TaskExportPDFEvent(success: true, file: file));
        _loading = false;
        notifyListeners();
      }
    );
  }

  Future<void> reorderTask(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _filteredTasks.length) return;
    if (newIndex < 0 || newIndex > _filteredTasks.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final TaskVo item = _filteredTasks.removeAt(oldIndex);
    _filteredTasks.insert(newIndex, item);

    notifyListeners();

    final result = await _taskRepository.update(
      id: item.id.toString(),
      position: newIndex
    );

    result.fold(
      (failure) {
        _loading = false;
        _errorKey = _mapFailureToKey(failure);
        _taskEventService.add(TaskUpdateEvent(success: false, failureKey: _errorKey));
        notifyListeners();
      },
      (updatedTask) {
        _taskEventService.add(TaskUpdateEvent(success: true));
        notifyListeners();
      }
    );
  }

  void searchTask(String query) {
    _searchQuery = query.trim();
    filterTasks(_filterMode);
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      return;
    }

    final searchTerms = _searchQuery.toLowerCase().split(' ').where((term) => term.isNotEmpty).toList();

    if (searchTerms.isEmpty) {
      return;
    }

    _filteredTasks = _filteredTasks.where((task) {
      final taskContent = [
        task.title.toLowerCase(),
        task.description?.toLowerCase() ?? '',
        task.category.description.toLowerCase(),
        ...task.subtaskList.map((s) => s.title.toLowerCase())
      ].join(' ');

      return searchTerms.every((term) => taskContent.contains(term));
    }).toList();
  }

  void _calculateCountTasks() {
    _countAllTasks = _tasks.length;
    _countTodayTasks = _filteredTasks.where((task) => (task.deadline as DateTime).isToday).length;
    _countNextWeekTasks = _filteredTasks.where((task) => (task.deadline as DateTime).isNextWeek).length;
    _countNextMonthTasks = _filteredTasks.where((task) => (task.deadline as DateTime).isNextMonth).length;
    _overdueTasks = _filteredTasks.where((task) => DateTime.now().isOverdue(task.deadline as DateTime)).length;
  }

  void filterTasks(FilteringTaskModeEnum filterMode) {
    _filterMode = filterMode;
    if (filterMode != FilteringTaskModeEnum.category) { _categoryViewmodel.selectedCategory = null; }

    List<dynamic> tasks = List.from(_tasks);

    switch (filterMode) {
      case FilteringTaskModeEnum.all:
        break;
      case FilteringTaskModeEnum.today:
        tasks = tasks.where((task) => (task.deadline as DateTime).isToday).toList();
        break;
      case FilteringTaskModeEnum.nextWeek:
        tasks = tasks.where((task) => (task.deadline as DateTime).isNextWeek).toList();
        break;
      case FilteringTaskModeEnum.nextMonth:
        tasks = tasks.where((task) => (task.deadline as DateTime).isNextMonth).toList();
        break;
      case FilteringTaskModeEnum.overdue:
        tasks = tasks.where((task) => DateTime.now().isOverdue(task.deadline as DateTime)).toList();
        break;
      case FilteringTaskModeEnum.category:
        if (_categoryViewmodel.selectedCategory != null) {
          tasks = tasks.where((task) => task.category.id == _categoryViewmodel.selectedCategory!.id).toList();
        }
        break;
    }
    _filteredTasks = tasks;
    _applySearchFilter();
    notifyListeners();
  }

  void clearAllFiltersForTasks() {
    _categoryViewmodel.selectedCategory = null;
    filterTasks(FilteringTaskModeEnum.all);
  }

  void clearErrorMessage() {
    _errorKey = null;
    notifyListeners();
  }

  Future<void> clearData() async {
    await _notificationService.cancelAllNotifications();

    _tasks = [];
    _filteredTasks = [];
    _filterMode = FilteringTaskModeEnum.all;
    _countAllTasks = 0;
    _countTodayTasks = 0;
    _countNextWeekTasks = 0;
    _countNextMonthTasks = 0;
  }

  TaskVo? findTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId) as TaskVo?;
    } catch (e) {
      return null;
    }
  }

  TaskVo? findParentTaskOfSubtask(String subtaskId) {
    try {
      return _tasks.firstWhere((task) => (task as TaskVo).subtaskList.any((subtask) => subtask.id == subtaskId)) as TaskVo?;
    } catch (e) {
      return null;
    }
  }
}
