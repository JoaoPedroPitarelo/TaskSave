import 'package:task_save/core/enums/file_type_enum.dart';
import 'package:task_save/domain/models/attachment_vo.dart';
import 'package:task_save/services/local_database/local_database_service.dart';
import 'package:sqflite/sqflite.dart';

class LocalAttachmentRepository {

  static Database? _database;
  static final LocalAttachmentRepository _instance = LocalAttachmentRepository._private();

  LocalAttachmentRepository._private();

  factory LocalAttachmentRepository() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await LocalDataBaseService.database;
    return _database!;
  }

  Future<bool> isExists(String attachmentId) async {
    final db = await database;

    final result = await db.query(
      "attachment",
      where: "id = ?",
      whereArgs: [attachmentId],
    );

    return result.isNotEmpty;
  }

  Future<bool> isDownloaded(String attachmentId) async {
    final attachment = await getById(attachmentId);
    return attachment!.isDownloaded!;
  }

  Future<String?> getFilePath(String attachmentId) async {
    final attachment = await getById(attachmentId);
    return attachment!.localFilePath;
  }

  /* InsertAttachment
  * O que esse métdo faz é inserir um novo anexo no banco de dados. Esse métdo não salva
  * o arquivo em disco. Ele apenas salva as informações do anexo no banco de dados.
  * */
  Future<void> insertAttachment(AttachmentVo attachment) async {
    final db = await database;

    if (await isExists(attachment.id)) {
      return;
    }

    await db.insert(
      'attachment',
      {
        "id": attachment.id,
        "task_id": attachment.taskId,
        "file_name": attachment.fileName,
        "file_type": attachment.fileType.index,
        "is_downloaded": 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> setDownloaded(AttachmentVo attachment, String filePath) async {
    final db = await database;

    await db.update(
      'attachment',
      {
        "is_downloaded": 1,
        "local_file_path": filePath
      },
      where: "id = ?",
      whereArgs: [attachment.id],
    );

    attachment.localFilePath = filePath;
    attachment.isDownloaded = true;
  }

  Future<int> deleteAttachment(String attachmentId) async {
    final db = await database;

    final result = await db.delete(
      'attachment',
      where: "id = ?",
      whereArgs: [attachmentId],
    );

    return result;
  }

  Future<AttachmentVo?> getById(String attachmentId) async {
    final db = await database;

    final result = await db.query(
      "attachment",
      where: "id = ?",
      whereArgs: [attachmentId],
    );

    return result.isNotEmpty
      ? AttachmentVo(
        id: result.first['id'].toString(),
        fileName: result.first['file_name'].toString(),
        fileType: FileTypeEnum.values[int.parse(result.first['file_type'].toString())],
        localFilePath: result.first['local_file_path']?.toString(),
        taskId: result.first['task_id'].toString(),
        isDownloaded: result.first['is_downloaded'].toString() == '1' ? true : false,
        active: true)
      : null;
  }

  Future<List<AttachmentVo>?> getAttachments(String taskId) async {
    final db = await database;

    final result = await db.query(
      "attachment",
      where: "task_id = ?",
      whereArgs: [taskId],
    );

    return result.isNotEmpty
      ? result.map((attach) => AttachmentVo(
          id: attach['id'].toString(),
          fileName: attach['file_name'].toString(),
          fileType: FileTypeEnum.values[int.parse(attach['file_type'].toString())],
          localFilePath: attach['local_file_path']?.toString(),
          taskId: attach['task_id'].toString(),
          isDownloaded: attach['is_downloaded'].toString() == '1' ? true : false,
          active: true
        )).toList()
      : null;
  }
}
