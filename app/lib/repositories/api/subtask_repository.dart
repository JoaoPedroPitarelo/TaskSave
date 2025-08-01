import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/core/errors/subtask_failures.dart';
import 'package:task_save/domain/enums/priority_enum.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/subtask_vo.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class SubtaskRepository {
  final Dio _dio;

  SubtaskRepository(this._dio);

  Future<Either<Failure, String?>> delete(TaskVo task, SubtaskVo subtask) async {
    try {
      final response = await _dio.delete(
        '/subtask/${subtask.id}'
      );

      return Right(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(SubtaskNotFoundFailure());
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
      PriorityEnum? priority,
      ReminderTypeNum? reminderType,
      int? position)
  {
    final payload = <String, dynamic>{};

    if (title != null) { payload['title'] = title; }
    if (description != null) { payload['description'] = description; }
    if (deadline != null) { payload['deadline'] = deadline.toIso8601String(); }
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
    int? categoryId,
    PriorityEnum? priority,
    ReminderTypeNum? reminderType,
    int? position,
  }) async {
    try {
      final response = await _dio.put(
        '/subtask/$id',
        data: _makePayload(title, description, deadline, priority, reminderType, position)
      );

      return Right(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(SubtaskNotFoundFailure());
      }
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> create(SubtaskVo subtask, String parentTaskId) async {
    try {
      final response = await _dio.post(
        '/subtask/create',
        data:  { ..._makePayload(
            subtask.title,
            subtask.description,
            subtask.deadline,
            subtask.priority,
            subtask.reminderType,
            null
          ),
          "parentTaskId": parentTaskId,
          }
        );

      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}