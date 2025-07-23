import 'dart:io';

import 'package:app/core/errors/attachment_failures.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/task_failures.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/enums/reminder_type_num.dart';
import 'package:app/domain/models/attachmentVo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/repositories/local/local_attachment_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class TaskRepository {
  final Dio _dio;
  final LocalAttachmentRepository _localAttachmentRepository;

  TaskRepository(this._dio, this._localAttachmentRepository);

  Future<Either<Failure, Map<String, dynamic>>> getAll() async {
    try {
      final response = await _dio.get(
        '/task',
      );

      for (var task in (response.data['tasks'] as List)) {
        if (task.containsKey('attachments') && (task['attachments'] as List).isNotEmpty ) {
          for (final attachment in task['attachments']) {
            await _localAttachmentRepository.insertAttachment(AttachmentVo.fromJson(attachment));
          }
        }
      }

      return Right(response.data);
    } on DioException catch (e) {

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {

      return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, String>> delete(TaskVo task) async {
    try {
      final response = await _dio.delete(
        '/task/${task.id}'
      );

      if (task.attachmentList.isNotEmpty) {
        for (final attachment in task.attachmentList) {
          await deleteAttachment(attachment);
        }
      }

      return Right(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(TaskNotFoundFailure());
      }
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  Map<String, dynamic> _makePayloadForUpdate(
      String? title,
      String? description,
      DateTime? deadline,
      int? categoryId,
      PriorityEnum? priority,
      ReminderTypeNum? reminderType,
      int? position)
  {
    final payload = <String, dynamic>{};

    if (title != null) { payload['title'] = title; }
    if (description != null) { payload['description'] = description; }
    if (deadline != null) { payload['deadline'] = deadline; }
    if (categoryId != null) { payload['category_id'] = categoryId; }
    if (priority != null) { payload['priority'] = priority.name; }
    if (reminderType != null) { payload['reminder_type'] = reminderType.name; }
    if (position != null) { payload['position'] = position; }

    return payload;
  }

  Future<Either<Failure, Map<String, dynamic>>> update({
    required String id,
    String? title,
    String? description,
    DateTime? deadline,
    int? categoryId,
    PriorityEnum? priority,
    ReminderTypeNum? reminderType,
    int? position,
  }) async {
    try {
      final response = await _dio.put(
        '/task/$id',
        data: _makePayloadForUpdate(title, description, deadline, categoryId, priority, reminderType, position),
      );

      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  // TODO criar método de criação de tarefas

  Future<Either<Failure, String?>> deleteAttachment(AttachmentVo attachment) async {

    if (!await _deleteLocalAttachment(attachment)) {
      return Left(AttachmentFailure());
    }

    try {
      final response = await _dio.delete(
          '/task/${attachment.taskId}/attachment/${attachment.id}'
      );

      return Right(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(AttachmentFailure());
      }
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  Future<bool> _deleteLocalAttachment(AttachmentVo attachment) async {
    try {
      attachment.localFilePath = await _localAttachmentRepository.getFilePath(attachment.id);

      // retorna true, por que realmente ele não existe no dispositivo
      if (attachment.localFilePath == null) {
        return true;
      }

      final File attachmentFile = File(attachment.localFilePath!);

      // verifica se o arquivo existe realmente
      final bool fileExists = await attachmentFile.exists();

      if (fileExists) {
        // Se existir deletamos do dispositivo
        await attachmentFile.delete();
      }

      // deleta do banco de dados local (sqflite)
      await _localAttachmentRepository.deleteAttachment(attachment.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /* Download attachment
  * Este é um metdo que abaixa o anexo quando ele não estiver salvo localmente e retorna o caminho do arquivo baixado
  * para posteriormente ser usado para mostrar o anexo na tela
  * */
  Future<Either<Failure, String>> downloadAttachment(AttachmentVo attachment) async {
    if (await _localAttachmentRepository.isDownloaded(attachment.id)) {
      attachment.localFilePath = await _localAttachmentRepository.getFilePath(attachment.id);
      print('Attachment already downloaded: ${attachment.localFilePath}');
      return Right(attachment.localFilePath!);
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${attachment.id}';

      await _dio.download(
        attachment.downloadLink!,
        filePath,
      );

      await _localAttachmentRepository.setDownloaded(attachment, filePath);

      return Right(filePath);
    } on DioException catch (e) {
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}