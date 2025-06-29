import 'package:app/core/errors/failure.dart';
import 'package:app/domain/exceptions/category_failures.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class CategoryRepository {
  final Dio _dio;

  CategoryRepository(this._dio);

  Future<Either<Failure, Map<String, dynamic>>> create(Map<String, dynamic> category) async {
    try {
      final response = await _dio.post(
        '/category',
        data: {
          'description': category["description"],
          'color': category["color"],
        },
      );

      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  Map<String, dynamic> _makePayloadForUpdate({String? description, String? color}) {
    final payload = <String, dynamic>{};
    if (description != null) {
      payload['description'] = description;
    }
    if (color != null) {
      payload['color'] = color;
    }
    return payload;
  }

  Future<Either<Failure, Map<String, dynamic>>> update({required String id, String? description, String? color}) async {
    try {
      final response = await _dio.put(
        '/category/$id',
        data: _makePayloadForUpdate(description: description, color: color),
      );

      return Right(response.data);
    } on DioException catch (e) {

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }


  Future<Either<Failure, Map<String, dynamic>>> getAll() async {
    try {
      final response = await _dio.get(
        '/category',
      );

      return Right(response.data);
    } on DioException catch (e) {

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {

      return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getById(String id) async {
    try {
      final response = await _dio.get(
        '/category/$id',
      );

      return Right(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(CategoryNotFoundException());
      }
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getCategoryById(String id) async {
    try {
      final response = await _dio.get(
        '/category/$id',
      );

      return Right(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(CategoryNotFoundException());
      }
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

}