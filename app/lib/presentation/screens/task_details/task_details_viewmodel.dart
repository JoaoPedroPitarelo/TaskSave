
import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/core/events/task_events.dart';
import 'package:app/domain/models/attachmentVo.dart';
import 'package:app/repositories/api/task_repository.dart';
import 'package:app/services/events/task_event_service.dart';
import 'package:flutter/cupertino.dart';

class TaskDetailsViewmodel extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final FailureKey Function(Failure) mapFailureToKey;
  final TaskEventService _taskEventService = TaskEventService();

  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  bool _loading = false;
  bool get isLoading => _loading;

  TaskDetailsViewmodel(this._taskRepository, this.mapFailureToKey);

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
        print("to aqui");
        _taskEventService.add(TaskDownloadAttachmentEvent(success: true, filePath: filePath));
      }
    );
  }

}
