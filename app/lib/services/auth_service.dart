import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/core/exceptions/duplicated_user_exception.dart';
import 'package:app/core/exceptions/user_not_found_exception.dart';
import 'package:app/core/exceptions/user_not_verified_exception.dart';
import 'package:app/models/user_vo.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Project
import 'package:app/utils/constants.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  final secureStorage = FlutterSecureStorage();

  Future<UserVo?> doLogin(String email, String password) async {
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
     
      return UserVo(id: jwtSub['id'].toString(), login: jwtSub['sub']);
    } else if (requestResponse.statusCode == 401) { // UNUATHORIZED
      throw UserNotFoundException("Invalid credential");
    } if (requestResponse.statusCode == 403) { // FORBIDDEN
      throw UserNotVerifiedException("User not verified");
    } else {
      throw Exception('Erro desconhecido: ${requestResponse.body}');
    }
  }

  Future<UserVo?> createLogin(String email, String password) async {
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
      return UserVo(id: responseBody['id'].toString(), login: responseBody['email']);
    } else if (requestResponse.statusCode == 409) {
      
      throw DuplicatedUserException("There is already a user registered with that email");
    } else {
      
      throw Exception('Unknown Error: ${requestResponse.body}');
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