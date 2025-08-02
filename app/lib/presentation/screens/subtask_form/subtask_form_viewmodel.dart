import 'package:task_save/core/enums/task_type_enum.dart';
import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/core/errors/failure_keys.dart';
import 'package:task_save/core/events/task_events.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/subtask_vo.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/repositories/api/subtask_repository.dart';
import 'package:task_save/services/events/task_event_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:task_save/services/notifications/notification_service.dart';

class SubtaskFormViewmodel extends ChangeNotifier {
  final SubtaskRepository _subtaskRepository;
  final NotificationService _notificationService;
  final _taskEventService = TaskEventService();

  bool _loading = false;
  bool get isLoading => _loading;

  final FailureKey Function(Failure) _mapFailureToKey;
  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  SubtaskFormViewmodel(this._subtaskRepository, this._notificationService, this._mapFailureToKey);

  Future<void> saveSubtask(SubtaskVo subtask, TaskVo task) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _subtaskRepository.create(subtask, task.id);

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _taskEventService.add(SubtaskCreationEvent(success: false, failureKey: _errorKey));
        _loading = false;
        notifyListeners();
      },
      (subtask) {
        _taskEventService.add(SubtaskCreationEvent(success: true, subtask: SubtaskVo.fromJson(subtask["subtask"])));
        _taskEventService.add(GetTasksEvent(success: true));
        _loading = false;
        notifyListeners();
      }
    );
  }

  Future<void> updateSubtask(SubtaskVo subtask) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _subtaskRepository.update(
      id: subtask.id,
      title: subtask.title,
      description: subtask.description,
      deadline: subtask.deadline,
      priority: subtask.priority,
      reminderType: subtask.reminderType,
    );

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _taskEventService.add(SubtaskUpdateEvent(success: false, failureKey: _errorKey));
        _loading = false;
        notifyListeners();
      },
      (modifiedTask) {
        if (subtask.reminderType == ReminderTypeNum.without_notification) {
          _notificationService.cancelNotificationsByPayload('{"id": "${subtask.id}", "taskType": "${TaskType.st.name}"}');
        }
        _taskEventService.add(SubtaskUpdateEvent(success: true, subtask: SubtaskVo.fromJson(modifiedTask["subtask"])));
        _taskEventService.add(GetTasksEvent(success: true));
        _loading = false;
        notifyListeners();
      }
    );
  }
}
