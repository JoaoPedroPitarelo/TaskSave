// Project
import 'package:app/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockStorage extends Mock implements FlutterSecureStorage {}

void main() async {
  
  test('Deveria retornar um token', () async {
    final storage = MockStorage();
    AuthService authService = AuthService();
  
    when(storage.read(key: 'jwtUser')).thenAnswer((_) async => '123');
    
    authService.doLogin("gclp2004@gmail.com", "Password123!");
    

    final token = await storage.read(key: 'jwtUser');


    expect(token, isNotEmpty);
  });
}