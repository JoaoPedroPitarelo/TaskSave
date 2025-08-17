import 'dart:io';

import 'package:task_save/core/errors/failure_keys.dart';
import 'package:task_save/domain/models/attachment_vo.dart';
import 'package:task_save/domain/models/subtask_vo.dart';
import 'package:task_save/domain/models/task_vo.dart';

abstract class TaskDataEvent {}

class GetTasksEvent extends TaskDataEvent {
  bool success = false;
  FailureKey? failureKey;

  GetTasksEvent({required this.success, this.failureKey});
}

class TaskCreationEvent extends TaskDataEvent {
  bool success = false;
  FailureKey? failureKey;
  TaskVo? task;

  TaskCreationEvent({required this.success, this.failureKey, this.task});
}

class TaskDeletionEvent extends TaskDataEvent {
  bool success = false;
  FailureKey? failureKey;
  TaskVo task;
  int originalIndex;

  TaskDeletionEvent(this.task, this.originalIndex);
}

class TaskUpdateEvent extends TaskDataEvent {
  final bool success;
  final FailureKey? failureKey;

  TaskUpdateEvent({required this.success, this.failureKey});
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

class TaskAttachmentUploadEvent extends TaskDataEvent {
  final bool success;
  final AttachmentVo? attachment;
  final FailureKey? failureKey;

  TaskAttachmentUploadEvent({required this.success, this.attachment, this.failureKey});
}

class SubtaskDeletionEvent extends TaskDataEvent {
  final bool? success;
  final FailureKey? failureKey;
  final TaskVo task;
  final SubtaskVo subtask;
  final int originalIndex;

  SubtaskDeletionEvent({
    this.success,
    this.failureKey,
    required this.task,
    required this.subtask,
    required this.originalIndex
  });
}

class SubtaskReorderEvent extends TaskDataEvent {
  final bool success;
  final FailureKey? failureKey;

  SubtaskReorderEvent({required this.success, this.failureKey});
}

class SubtaskCreationEvent extends TaskDataEvent {
  bool success = false;
  FailureKey? failureKey;
  SubtaskVo? subtask;

  SubtaskCreationEvent({required this.success, this.failureKey, this.subtask});
}

class SubtaskUpdateEvent extends TaskDataEvent {
  bool success = false;
  FailureKey? failureKey;
  SubtaskVo? subtask;

  SubtaskUpdateEvent({required this.success, this.failureKey, this.subtask});
}

class TaskExportPDFEvent extends TaskDataEvent {
  bool success = false;
  FailureKey? failureKey;
  File? file;

  TaskExportPDFEvent({required this.success, this.failureKey, this.file});
}

