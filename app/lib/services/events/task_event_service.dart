import 'dart:async';
import 'package:app/core/events/task_events.dart';

class TaskEventService {
  static final TaskEventService _instance = TaskEventService._internal();

  TaskEventService._internal();

  factory TaskEventService() {
    return _instance;
  }

  final StreamController<TaskDataEvent> _taskEventsController = StreamController<TaskDataEvent>.broadcast();
  Stream<TaskDataEvent> get onTaskChanged => _taskEventsController.stream;

  void add(TaskDataEvent event) {
    _taskEventsController.add(event);
  }

  void dispose() {
    _taskEventsController.close();
  }
}