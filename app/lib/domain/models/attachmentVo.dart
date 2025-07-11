import 'package:app/domain/enums/file_type_enum.dart';

class AttachmentVo {
  final String id;
  final String filePath;
  final String fileName;
  final FileTypeEnum filetype;
  final String downloadLink;
  final DateTime uploadedAt;
  final bool active;

  AttachmentVo({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.filetype,
    required this.downloadLink,
    required this.uploadedAt,
    required this.active
  });

  factory AttachmentVo.fromJson(Map<String, dynamic> json) {
    return AttachmentVo(
      id: json['id'].toString(),
      filePath: json['filePath'],
      fileName: json['fileName'],
      filetype: FileTypeEnum.values.firstWhere((fileType) => fileType.name == json['fileType']),
      downloadLink: json['downloadEndPoint'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      active: json['ativo'],
    );
  }
}
