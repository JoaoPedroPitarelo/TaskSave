import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/core/errors/failure_keys.dart';
import 'package:task_save/core/events/task_events.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/repositories/api/task_repository.dart';
import 'package:task_save/services/events/task_event_service.dart';
import 'package:flutter/cupertino.dart';

class TaskFormViewmodel extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final _taskEventService = TaskEventService();

  bool _loading = false;
  bool get isLoading => _loading;

  final FailureKey Function(Failure) _mapFailureToKey;
  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  TaskFormViewmodel(this._taskRepository, this._mapFailureToKey);

  Future<void> saveTask(TaskVo task) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _taskRepository.create(task);

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _taskEventService.add(TaskCreationEvent(success: false, failureKey: _errorKey));
        _loading = false;
        notifyListeners();
      },
      (task) {
        _loading = false;
        _taskEventService.add(TaskCreationEvent(success: true));
        _taskEventService.add(GetTasksEvent(success: true));
        notifyListeners();
      }
    );
  }

  Future<void> updateTask(TaskVo task) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _taskRepository.update(
      id: task.id,
      title: task.title,
      description: task.description,
      deadline: task.deadline,
      priority: task.priority,
      reminderType: task.reminderType,
      category: task.category
    );

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _taskEventService.add(TaskUpdateEvent(success: false, failureKey: _errorKey));
        _loading = false;
        notifyListeners();
      },
      (task) {
        _loading = false;
        _taskEventService.add(TaskUpdateEvent(success: true));
        _taskEventService.add(GetTasksEvent(success: true));
        notifyListeners();
      }
    );
  }
}