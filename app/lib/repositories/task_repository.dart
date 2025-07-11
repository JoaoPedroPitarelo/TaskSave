import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/task_failures.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/enums/reminder_type_num.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class TaskRepository {
  final Dio _dio;

  TaskRepository(this._dio);

  Future<Either<Failure, Map<String, dynamic>>> getAll() async {
    try {
      final response = await _dio.get(
        '/task',
      );

      return Right(response.data);
    } on DioException catch (e) {

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {

      return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, String>> delete(String id) async {
    try {
      final response = await _dio.delete(
        '/task/$id'
      );

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
    int? position) {
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

}