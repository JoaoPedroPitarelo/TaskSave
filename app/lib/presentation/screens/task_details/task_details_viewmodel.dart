import 'dart:io';
import 'dart:typed_data';
import 'package:task_save/core/enums/task_type_enum.dart';
import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/core/errors/failure_keys.dart';
import 'package:task_save/core/events/task_events.dart';
import 'package:task_save/domain/models/attachment_vo.dart';
import 'package:task_save/domain/models/subtask_vo.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/presentation/screens/task_details/download_status.dart';
import 'package:task_save/repositories/api/attachment_repository.dart';
import 'package:task_save/repositories/api/subtask_repository.dart';
import 'package:task_save/services/events/task_event_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:task_save/services/notifications/notification_service.dart';

class TaskDetailsViewmodel extends ChangeNotifier {
  final AttachmentRepository _attachmentRepository;
  final SubtaskRepository _subtaskRepository;
  final FailureKey Function(Failure) mapFailureToKey;
  final NotificationService _notificationService;
  final TaskEventService _taskEventService = TaskEventService();

  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  bool _loading = false;
  bool get isLoading => _loading;

  Map<String, DownloadStatus> _attachmentStatus = {};
  Map<String, DownloadStatus> get attachmentStatus => _attachmentStatus;

  List<SubtaskVo> _subtaskList = [];
  List<SubtaskVo> get subtaskList => _subtaskList;

  TaskDetailsViewmodel(this._attachmentRepository, this._subtaskRepository, this._notificationService, this.mapFailureToKey);

  Future<void> initializeAttachmentsStatus(TaskVo task) async {
    if (task.attachmentList.isEmpty) return;
    _loading = true;

    final downloadedAttachmentList = await _attachmentRepository.getAttachments(task.id);

    if (downloadedAttachmentList == null) {
      _initializeDownloadStatusNotDownloadedAttachments(task);
      return;
    }

    _initializeDownloadStatusDownloadedAttachments(task, downloadedAttachmentList);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> initializeSubtaskList(List<SubtaskVo> subtaskList) async {
    _loading = true;
    _subtaskList = subtaskList;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loading = false;
      notifyListeners();
    });
  }

  void addSubtask(SubtaskVo subtask) {
    _subtaskList.add(subtask);
    notifyListeners();
  }

  void updateSubtask(SubtaskVo subtask) {
    _subtaskList.removeWhere((element) => element.id == subtask.id);
    _subtaskList.add(subtask);
    notifyListeners();
  }

  void _initializeDownloadStatusNotDownloadedAttachments(TaskVo task) {
    _attachmentStatus = {
      for (var attachment in task.attachmentList)
        attachment.id: DownloadStatus()
    };

    notifyListeners();
    _loading = false;
  }

  void _initializeDownloadStatusDownloadedAttachments(TaskVo task, List<AttachmentVo> downloadedAttachmentList) {
    for (var attachment in task.attachmentList) {
      for (var downloadedAttachment in downloadedAttachmentList) {
        if (downloadedAttachment.id == attachment.id) {
          attachment.isDownloaded = downloadedAttachment.isDownloaded;
          attachment.localFilePath = downloadedAttachment.localFilePath;
        }
      }
    }

    _attachmentStatus = {
      for (var attachment in task.attachmentList)
        attachment.id: attachment.isDownloaded == true
            ? DownloadStatus(state: DownloadState.completed, progress: 1.0)
            : DownloadStatus()
    };
  }

  Future<void> downloadAttachment(AttachmentVo attachment) async {
    if (_attachmentStatus[attachment.id]?.state == DownloadState.downloading) return;

    _attachmentStatus[attachment.id] = DownloadStatus(state: DownloadState.downloading, progress: 0.0);
    notifyListeners();

    final result = await _attachmentRepository.downloadAttachment(attachment, onReceiveProgress: (rec, total) {
        final progress = total != -1 ? rec / total : -1.0;
        _attachmentStatus[attachment.id] = DownloadStatus(state: DownloadState.downloading, progress: progress);
        notifyListeners();
      }
    );

    result.fold(
      (failure) {
        _errorKey = mapFailureToKey(failure);
        _attachmentStatus[attachment.id] = DownloadStatus(state: DownloadState.failed);
        _taskEventService.add(TaskDownloadAttachmentEvent(success: false, failureKey: _errorKey));
        notifyListeners();
      },(filePath) {
        attachment.localFilePath = filePath;
        _attachmentStatus[attachment.id] = DownloadStatus(state: DownloadState.completed, progress: 1.0);
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

    final result = await _attachmentRepository.deleteAttachment(attachment);
    
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

  Future<void> uploadAttachment(File file, TaskVo task) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _attachmentRepository.uploadAttachment(file, task.id);

    result.fold(
      (failure) {
        _loading = false;
        _errorKey = mapFailureToKey(failure);
        _taskEventService.add(TaskAttachmentUploadEvent(success: false, failureKey: _errorKey));
        notifyListeners();
      },
      (attachment) {
        _loading = false;
        task.attachmentList.add(attachment);
        _taskEventService.add(TaskAttachmentUploadEvent(success: true, attachment: attachment));
        notifyListeners();
      },
    );
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

  Future<void> confirmSubtaskDeletion(TaskVo task, SubtaskVo subtask, originalIndex) async {
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
        _notificationService.cancelNotificationsByPayload('{"id": "${subtask.id}", "taskType": "${TaskType.st.name}"}');
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
