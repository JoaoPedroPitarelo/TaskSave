import 'package:task_save/core/errors/category_failures.dart';
import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/core/errors/task_failures.dart';
import 'package:task_save/domain/enums/priority_enum.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/attachment_vo.dart';
import 'package:task_save/domain/models/category_vo.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/repositories/api/attachment_repository.dart';
import 'package:task_save/repositories/local/local_attachment_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class TaskRepository {
  final Dio _dio;
  final LocalAttachmentRepository _localAttachmentRepository;
  final AttachmentRepository _attachmentRepository;

  TaskRepository(this._dio, this._localAttachmentRepository, this._attachmentRepository);

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
          await _attachmentRepository.deleteAttachment(attachment);
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

  Map<String, dynamic> _makePayload(
      String? title,
      String? description,
      DateTime? deadline,
      CategoryVo? category,
      PriorityEnum? priority,
      ReminderTypeNum? reminderType,
      int? position)
  {
    final payload = <String, dynamic>{};

    if (title != null) { payload['title'] = title; }
    if (description != null) { payload['description'] = description; }
    if (deadline != null) { payload['deadline'] = deadline.toIso8601String(); }
    if (category != null) { payload['categoryId'] = category.id; }
    if (priority != null) { payload['priority'] = priority.name.toUpperCase(); }
    if (reminderType != null) { payload['reminderType'] = reminderType.name.toUpperCase(); }
    if (position != null) { payload['position'] = position; }

    return payload;
  }

  Future<Either<Failure, Map<String, dynamic>>> update({
    required String id,
    String? title,
    String? description,
    DateTime? deadline,
    CategoryVo? category,
    PriorityEnum? priority,
    ReminderTypeNum? reminderType,
    int? position,
  }) async {
    try {
      print(_makePayload(title, description, deadline, category, priority, reminderType, position));

      final response = await _dio.put(
        '/task/$id',
        data: _makePayload(
          title,
          description,
          deadline,
          category,
          priority,
          reminderType,
          position
        ),
    );

      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> create(TaskVo   task) async {
    try {
      final response = await _dio.post(
        '/task/create',
        data: _makePayload(
          task.title,
          task.description,
          task.deadline,
          task.category,
          task.priority,
          task.reminderType,
          null
        )
      );

      return Right(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(CategoryNotFoundFailure());
      }
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}