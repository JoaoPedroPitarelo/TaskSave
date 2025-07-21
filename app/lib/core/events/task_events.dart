import 'package:app/core/errors/failure_keys.dart';
import 'package:app/domain/models/attachmentVo.dart';
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

class TaskDownloadAttachmentEvent extends TaskDataEvent {
  final bool success;
  final String? filePath;
  final FailureKey? failureKey;

  TaskDownloadAttachmentEvent({required this.success, this.filePath, this.failureKey});
}

class TaskAttachmentSavedAsEvent extends TaskDataEvent {
  final bool success;
  final String? fileName;

  TaskAttachmentSavedAsEvent({required this.success, this.fileName});
}

class TaskAttachmentDeletedEvent extends TaskDataEvent {
  final bool success;
  final AttachmentVo? attachment;
  final FailureKey? failureKey;

  TaskAttachmentDeletedEvent({required this.success, this.attachment, this.failureKey});
}

