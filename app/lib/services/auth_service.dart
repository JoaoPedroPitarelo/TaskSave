import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/core/errors/failure.dart';
import 'package:app/domain/exceptions/auth_failures.dart';
import 'package:app/domain/models/user_vo.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Project
import 'package:app/core/constants/url_api_constant.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  final secureStorage = FlutterSecureStorage();


  // Either<> -> "Qualquer" | Left -> erro, falha, caminho ruim | Right -> sucesso, acerto, caminho bom
  Future<Either<Failure, UserVo>> doLogin(String email, String password) async {
    
    try {
      final requestResponse = await http.post(
        Uri.parse("$apiurl/login"),
        headers: {
          "Content-Type": "application/json"},
        body: jsonEncode({
          "login": email,
          "password": password
        })
      );

      if (requestResponse.statusCode == 200) { // OK
        final accessToken = jsonDecode(requestResponse.body)["accessToken"];
        final refreshToken = jsonDecode(requestResponse.body)["refreshToken"];

        await secureStorage.write(key: "accessToken", value: accessToken);
        await secureStorage.write(key: "refreshToken", value: refreshToken);

        Map<String, dynamic> jwtSub = Jwt.parseJwt(accessToken);
      
        return Right(UserVo(id: jwtSub['id'].toString(), login: jwtSub['sub']));
      } 
      
      if (requestResponse.statusCode == 401) { // UNUATHORIZED
        return Left(InvalidCredentialsFailure());
      } 
      
      if (requestResponse.statusCode == 403) { // FORBIDDEN
        return Left(UserNotVerifiedFailure());
      } 
      
      if (requestResponse.statusCode >= 500) {
        return Left(ServerFailure(
          message: "Unexpected Internal Server error", 
          statusCode: requestResponse.statusCode
          )
        );
      } else {
        // Outros erros Http
        return Left(UnexpectedFailure("Unknown response: ${requestResponse.statusCode} - ${requestResponse.body}"));
      }
    } on SocketException {
      // Erros de rede/conexão
      return Left(NoConnectionFailure());
    } on FormatException catch (e) {
      // Erros relacionado ao formato do Json retornado
      return Left(UnexpectedFailure("Invalid/unexpeted JSON format: ${e.message}"));
    } catch (e) {
      // Qualquer outra exceção não mapeada
      return Left(UnexpectedFailure("Unknown error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, UserVo>> createLogin(String email, String password, String confirmedPassword) async {
    try {
        if (password != confirmedPassword) {
          return Left(PasswordsAreNotSameFailure());
        }
        
        final requestResponse = await http.post(
          Uri.parse("$apiurl/login/create"),
          headers: {
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "login": email,
            "password": password
            })
        );


      if (requestResponse.statusCode == 201) {
        Map<String, dynamic> responseBody = jsonDecode(requestResponse.body);
        return Right(UserVo(id: responseBody['user']['id'].toString(), login: responseBody['user']['email']));
      }

      if (requestResponse.statusCode == 409) {  
        return Left(DuplicatedEmailFailure());
      } 
      
      if (requestResponse.statusCode >= 500) {
        return Left(ServerFailure(message: "Unexpected Internal server error", statusCode: requestResponse.statusCode));
      } else {
        return Left(UnexpectedFailure("Unknowk response: ${requestResponse.statusCode} - ${requestResponse.body}"));
      }
    } on SocketException {
      // erros de rede/conexão
      return Left(NoConnectionFailure());
    } on FormatException catch (e) {
      return Left(UnexpectedFailure("Invalid/unexpected JSON format: ${e.message}"));
    } catch (e) {
      return Left(UnexpectedFailure("Unknown error: ${e.toString()}"));
    }
  }

  Future<bool> isAuthenticated() async {
    final refreshToken = await secureStorage.read(key: "refreshToken");
    
    if (refreshToken != null) {
      refreshAccessToken();
      return true;
    }

    return false;
  }
  

  // Adaptar isso ao Either<Left, Right>
  Future<void> refreshAccessToken() async {
    final refreshToken = await secureStorage.read(key: "refreshToken");
    final http.Response response;

    if (refreshToken == null) {
      throw Exception("RefreshToken not found");
    }

    try {
      response = await http.post(
        Uri.parse("$apiurl/login/refresh"), 
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "refreshToken": refreshToken
          })
        );
    } on SocketException {
      throw SocketException("server connection not found");
    } on TimeoutException {
      throw TimeoutException("the server took to long for respond");
    }

    if (response.statusCode.toInt() == 200) {
      final accessToken = jsonDecode(response.body)["accessToken"];
      final refreshToken = jsonDecode(response.body)["refreshToken"];

      await secureStorage.write(key: "accessToken", value: accessToken);
      await secureStorage.write(key: "refreshToken", value: refreshToken);
    } else {
      throw Exception("Error in request ${response.statusCode.toString()}");
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
  }
}