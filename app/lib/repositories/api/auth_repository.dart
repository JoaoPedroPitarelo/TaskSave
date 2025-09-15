import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/core/errors/auth_failures.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Either<Failure, Map<String, dynamic>>> loginRequest(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'login': email,
          'password': password
        },
      );

      return right(response.data);
    } on DioException catch (e) { // qualquer um que não seja 200, 201 ...
      if (e.type == DioExceptionType.connectionTimeout) {
        return Left(NoConnectionFailure());
      }

      if (e.response?.statusCode == 401) {
        return Left(InvalidCredentialsFailure());
      }

      if (e.response?.statusCode == 428) {
        return Left(UserNotVerifiedFailure());
      }

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {

      return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> registerRequest(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login/create',
        data: {
          'login': email,
          'password': password
        }
      );

      return right(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return Left(DuplicatedEmailFailure());
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        return Left(NoConnectionFailure());
      }

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> refreshTokenRequest(String refreshToken) async {
    try {
      final request = await _dio.post(
        '/login/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (request.statusCode == 200) {
        return right(request.data);
      }

      return Left(ServerFailure(message: "Failed to refresh tokens: ", statusCode: request.statusCode ?? 500));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return Left(NoConnectionFailure());
      }

      if (e.response?.statusCode == 401) {
        return Left(InvalidOrExpiredTokenFailure());
      }

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
     return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> passwordRescueRequest(String email) async {
    try {
      final response = await _dio.post(
        '/login/rescue',
        data: {'email': email}
      );

      if (response.statusCode == 200) {
        return right(response.data);
      }

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: response.statusCode ?? 500));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return Left(NoConnectionFailure());
      }

      if (e.response?.statusCode == 404) {
        return Left(UserNotFoundFailure());
      }

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, Null>> passwordChangeRequest(String rescueToken, String newPassword) async {
    try {
      final response = await _dio.put(
        '/login/rescue',
        data: {
          'token': rescueToken,
          'newPassword': newPassword
        }
      );

      if (response.statusCode == 204) {
        return right(null);
      }
    
      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: response.statusCode ?? 500));
    } on DioException catch (e){
      if (e.type == DioExceptionType.connectionTimeout) {
        return Left(NoConnectionFailure());
      }

      if (e.response?.statusCode == 401) {
        return Left(InvalidOrExpiredTokenFailure());
      }

      return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}