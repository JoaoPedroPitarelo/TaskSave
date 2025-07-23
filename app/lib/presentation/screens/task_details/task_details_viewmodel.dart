
import 'dart:io';
import 'dart:typed_data';

import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/core/events/task_events.dart';
import 'package:app/domain/models/attachmentVo.dart';
import 'package:app/domain/models/subtask_vo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/repositories/api/subtask_repository.dart';
import 'package:app/repositories/api/task_repository.dart';
import 'package:app/services/events/task_event_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class TaskDetailsViewmodel extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final SubtaskRepository _subtaskRepository;
  final FailureKey Function(Failure) mapFailureToKey;
  final TaskEventService _taskEventService = TaskEventService();

  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  bool _loading = false;
  bool get isLoading => _loading;

  TaskDetailsViewmodel(this._taskRepository, this._subtaskRepository, this.mapFailureToKey);

  Future<void> downloadAttachment(AttachmentVo attachment) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _taskRepository.downloadAttachment(attachment);

    result.fold(
      (failure) {
        _errorKey = mapFailureToKey(failure);
        _loading = false;
        _taskEventService.add(TaskDownloadAttachmentEvent(success: false, failureKey: _errorKey));
        notifyListeners();
      },(filePath) {
        _loading = false;
        notifyListeners();
        _taskEventService.add(TaskDownloadAttachmentEvent(success: true, filePath: filePath));
      }
    );
  }

  Future<void> saveAsAttachment(AttachmentVo attachment, String dialogTitle) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final Uint8List file = File(attachment.localFilePath!).readAsBytesSync();

      String? pathWhereFileIsSaved = await FilePicker.platform.saveFile(
          dialogTitle: dialogTitle,
          fileName: attachment.fileName,
          allowedExtensions: ["pdf", "jpg", "png", "jpeg"],
          type: FileType.custom,
          bytes: file
      );

      if (pathWhereFileIsSaved != null) {
        _loading = false;
        _taskEventService.add(TaskAttachmentSavedAsEvent(success: true, fileName: attachment.fileName));
        notifyListeners();
        return;
      }

      if (pathWhereFileIsSaved == null) {
        _loading = false;
        _taskEventService.add(TaskAttachmentSavedAsEvent(success: false));
        notifyListeners();
        return;
      }
    } catch (e) {
      _errorKey = FailureKey.attachmentError;
      _loading = false;
    }
  }

  Future<void> deleteAttachment(AttachmentVo attachment) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _taskRepository.deleteAttachment(attachment);
    
    result.fold(
    (failure) {
      _loading = false;
      _errorKey = mapFailureToKey(failure);
      _taskEventService.add(TaskAttachmentDeletedEvent(success: false, failureKey: _errorKey));
      notifyListeners();
    },
    (noContent) {
      _loading = false;
      _taskEventService.add(TaskAttachmentDeletedEvent(success: true, attachment: attachment));
      notifyListeners();
    });
  }

  void prepareSubtaskForDeletion(TaskVo task, SubtaskVo subtask) {
    final originalIndex = task.subtaskList.indexOf(subtask);
    if (originalIndex == -1) return;

    task.subtaskList.removeAt(originalIndex);

    _taskEventService.add(SubtaskDeletionEvent(
        task: task,
        subtask: subtask,
        originalIndex: originalIndex
    ));
    notifyListeners();
  }

  void undoDeletionSubtask(TaskVo task, SubtaskVo subtask, int originalIndex) {
    if (!task.subtaskList.contains(subtask)) {
      task.subtaskList.insert(originalIndex.clamp(0, task.subtaskList.length), subtask);
      notifyListeners();
    }
  }

  Future<void> confirmDeletionSubtask(task, subtask, originalIndex) async {
    final result = await _subtaskRepository.delete(task, subtask);

    result.fold(
      (failure) {
        _loading = false;
        _errorKey = mapFailureToKey(failure);
        undoDeletionSubtask(task, subtask, originalIndex);
        _taskEventService.add(SubtaskDeletionEvent(
            success: false,
            failureKey: _errorKey,
            task: task,
            subtask: subtask,
            originalIndex: originalIndex
        ));
        notifyListeners();
      },
      (noContent) {
        notifyListeners();
      }
    );
  }

  Future<void> reorderSubtask(TaskVo task, SubtaskVo subtask, int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= task.subtaskList.length) return;
    if (newIndex < 0 || newIndex > task.subtaskList.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final SubtaskVo item = task.subtaskList.removeAt(oldIndex);
    task.subtaskList.insert(newIndex, item);
    notifyListeners();

    final result = await _subtaskRepository.update(id: subtask.id, position: newIndex);

    result.fold(
      (failure) {
        _loading = false;
        _errorKey = mapFailureToKey(failure);
        _taskEventService.add(SubtaskReorderEvent(success: false, failureKey: _errorKey));
        notifyListeners();
      },
      (updatedSubtask) {
        _taskEventService.add(SubtaskReorderEvent(success: true));
        notifyListeners();
      }
    );
  }
}
