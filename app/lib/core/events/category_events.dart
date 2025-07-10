import 'package:app/core/errors/failure_keys.dart';
import 'package:app/domain/models/category_vo.dart';

abstract class CategoryDataEvent {}

class CategoriesChangedEvent extends CategoryDataEvent {
  bool isCreating = false;

  CategoriesChangedEvent({required this.isCreating});
}

class CategoryCreatedEvent extends CategoryDataEvent {
  final bool success;
  FailureKey? failureKey;

  CategoryCreatedEvent({required this.success, failureKey});
}

class CategoryUpdatingEvent extends CategoryDataEvent {
  final FailureKey? failureKey;
  final bool success;

  CategoryUpdatingEvent({required this.success, this.failureKey});
}

class CategoryDeletionEvent extends CategoryDataEvent {
  final CategoryVo category;
  final int originalIndex;

  CategoryDeletionEvent(this.category, this.originalIndex);
}

class CategoryReorderEvent extends CategoryDataEvent {
  final bool success;
  final FailureKey? failureKey;

  CategoryReorderEvent({required this.success, this.failureKey});
}