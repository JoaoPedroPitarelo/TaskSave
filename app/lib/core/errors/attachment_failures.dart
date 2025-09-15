import 'package:task_save/core/errors/failure.dart';

class AttachmentFailure extends Failure {
  const AttachmentFailure();
}

class AttachmentNetworkFailure extends Failure {
  const AttachmentNetworkFailure();
}

class AttachmentServerFailure extends Failure {
  final int? statusCode;
  const AttachmentServerFailure({this.statusCode});
}

class AttachmentStorageFailure extends Failure {
  const AttachmentStorageFailure();
}
