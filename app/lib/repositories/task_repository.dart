import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/task_failures.dart';
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

}