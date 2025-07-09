
import 'package:app/core/errors/failure_keys.dart';

abstract class TaskDataEvent {}

class GetTasksEvent extends TaskDataEvent {
  bool success = false;
  FailureKey? failureKey;

  GetTasksEvent({required this.success, this.failureKey});
}
