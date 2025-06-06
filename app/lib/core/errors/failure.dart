import 'package:equatable/equatable.dart';

// Classe abstrata(não vai ser instâncidada), quer será usada como base para nossas falhas
// Por que Equatable?
// Como o equatable conseguimos comparar objetos de forma a ver pelos atributos deles e não o endereço de memória
// Assim conseguimos ver se a = Falha(1, "Erro tal") e b = Falha(1, "Erro tal") são iguais
// Será muito útil para comparar instâncias de falhas levando em conta seus conteúdos
abstract class Failure extends Equatable {
  final List<dynamic> properties;

  const Failure([this.properties = const <dynamic>[]]);
  
  @override
  List<Object?> get props => [properties];
} 

// Erros inesperados ou não mapeados
class UnexpectedFailure extends Failure {
  final String? message;
  
  const UnexpectedFailure([this.message]);

  @override
  List<Object?> get props => [message];
}

// Erros de conexão/rede
class NoConnectionFailure extends Failure {
  const NoConnectionFailure();

  @override
  List<Object?> get props => [];
}

// Falha para erros genéricos do servidor (500..)
class ServerFailure extends Failure {
  final String? message;
  final int? statusCode;

  const ServerFailure({this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}
