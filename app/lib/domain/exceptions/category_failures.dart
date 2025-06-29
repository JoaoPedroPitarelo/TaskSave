import 'package:app/core/errors/failure.dart';

class CategoryNotFoundException extends Failure {
  const CategoryNotFoundException();

  @override
  List<Object?> get props => [];
}
