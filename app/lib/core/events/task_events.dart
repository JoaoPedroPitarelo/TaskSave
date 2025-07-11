import 'package:app/core/errors/failure_keys.dart';
import 'package:app/domain/models/task_vo.dart';

abstract class TaskDataEvent {}

class GetTasksEvent extends TaskDataEvent {
  bool success = false;
  FailureKey? failureKey;

  GetTasksEvent({required this.success, this.failureKey});
}

class TaskDeletionEvent extends TaskDataEvent {
  bool success = false;
  FailureKey? failureKey;
  TaskVo task;
  int originalIndex;

  TaskDeletionEvent(this.task, this.originalIndex);
}

class TaskReorderEvent extends TaskDataEvent {
  final bool success;
  final FailureKey? failureKey;

  TaskReorderEvent({required this.success, this.failureKey});
}
