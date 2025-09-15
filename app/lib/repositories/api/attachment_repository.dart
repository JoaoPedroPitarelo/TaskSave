import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_save/core/errors/attachment_failures.dart';
import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/domain/models/attachment_vo.dart';
import 'package:task_save/repositories/local/local_attachment_repository.dart';

class AttachmentRepository {
  final Dio _dio;
  final LocalAttachmentRepository _localAttachmentRepository;

  AttachmentRepository(this._dio ,this._localAttachmentRepository);

  /* Download attachment
  * Este é um metodo que abaixa o anexo quando ele não estiver salvo localmente e retorna o caminho do arquivo baixado
  * para posteriormente ser usado para mostrar o anexo na tela
  * */
  Future<Either<Failure, String>> downloadAttachment(AttachmentVo attachment, {Function(int, int)? onReceiveProgress}) async {
    if (await _localAttachmentRepository.isDownloaded(attachment.id)) {
      attachment.localFilePath = await _localAttachmentRepository.getFilePath(attachment.id);
      return Right(attachment.localFilePath!);
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${attachment.id}';

      await _dio.download(
        attachment.downloadLink!,
        filePath,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        )
      );

      await _localAttachmentRepository.setDownloaded(attachment, filePath);

      return Right(filePath);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout) {
        return Left(AttachmentNetworkFailure());
      }
      if (e.type == DioExceptionType.badResponse) {
        return Left(AttachmentServerFailure(statusCode: e.response?.statusCode));
      }
      return Left(UnexpectedFailure());
    } catch (e) {
      return Left(AttachmentStorageFailure());
    }
  }

  Future<Either<Failure, AttachmentVo>> uploadAttachment(File file, String taskId) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'taskId': taskId,
      });

      final response = await _dio.post(
        '/task/attachment/upload',
        data: formData,
        options: Options(
          headers: {
            Headers.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        final newAttachment = AttachmentVo.fromJson(response.data["attachment"]);
        await _localAttachmentRepository.insertAttachment(newAttachment);
        return Right(newAttachment);
      } else {
        return Left(AttachmentServerFailure(statusCode: response.statusCode));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout) {
        return Left(AttachmentNetworkFailure());
      }
      if (e.type == DioExceptionType.badResponse) {
        return Left(AttachmentServerFailure(statusCode: e.response?.statusCode));
      }
      return Left(UnexpectedFailure());
    } catch (e) {
      return Left(AttachmentStorageFailure());
    }
  }

  Future<List<AttachmentVo>?> getAttachments(String taskId) async {
    final attachments = await _localAttachmentRepository.getAttachments(taskId);
    return attachments;
  }

  Future<bool> _deleteLocalAttachment(AttachmentVo attachment) async {
    try {
      attachment.localFilePath = await _localAttachmentRepository.getFilePath(attachment.id);

      if (attachment.localFilePath == null) {
        return true;
      }

      final File attachmentFile = File(attachment.localFilePath!);

      final bool fileExists = await attachmentFile.exists();

      if (fileExists) {
        await attachmentFile.delete();
      }

      await _localAttachmentRepository.deleteAttachment(attachment.id);
      return true;
    } catch (e) {
      return false;
    }
  }

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
}
