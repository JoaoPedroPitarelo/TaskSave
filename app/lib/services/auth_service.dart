import 'dart:convert';

import 'package:app/models/user_vo.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Project
import 'package:app/utils/contants.dart';
import 'package:jwt_decode/jwt_decode.dart';

// TODO acredito que esteja funcionando, porém ainda falta testes melhores
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

    if (requestResponse.statusCode.toInt() == 200) {
      final token = jsonDecode(requestResponse.body)["token"];
      await secureStorage.write(key: "jwtUser", value: token);
      
      Map<String, dynamic> jwtPayload = Jwt.parseJwt(token);

      return UserVo(id: jwtPayload['id'], login: jwtPayload['sub']);
    } else {
      return null;
    }
  }

  Future<bool> isAuthenticate() async {
    final jwtToken = await secureStorage.read(key: "jwtUser");

    if (jwtToken == null) { return false; }
  }

  Future<String?> getToken() async{
    final token = secureStorage.read(key: "jwtUser");
    return token;
  }

  // Logout a gente delete do Flutter secrete_storage
  Future<void> logout() async {
    await secureStorage.delete(key: 'jwtUser');
  }
}