import 'package:task_save/core/enums/file_type_enum.dart';

class AttachmentVo {
  final String id;
  String? localFilePath;
  final String fileName;
  final FileTypeEnum fileType;
  String? downloadLink;
  DateTime? uploadedAt;
  final String taskId;
  bool? isDownloaded = false;
  bool active;

  AttachmentVo({
    required this.id,
    required this.fileName,
    required this.fileType,
    this.downloadLink,
    this.localFilePath,
    this.uploadedAt,
    this.isDownloaded,
    required this.taskId,
    required this.active
  });

  factory AttachmentVo.fromJson(Map<String, dynamic> json) {
    return AttachmentVo(
      id: json['id'].toString(),
      taskId: json['taskId'].toString(),
      fileName: json['fileName'],
      fileType: FileTypeEnum.values.firstWhere((fileType) => fileType.name == json['fileType']),
      downloadLink: json['downloadEndPoint'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      active: json['ativo'],
    );
  }
}
