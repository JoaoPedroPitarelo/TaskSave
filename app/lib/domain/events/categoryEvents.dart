import 'package:app/domain/models/category_vo.dart';

abstract class CategoryDataEvent {}

class CategoriesChangedEvent extends CategoryDataEvent {
  bool isCreating = false;

  CategoriesChangedEvent({required this.isCreating});
}

class CategoryCreatedEvent extends CategoryDataEvent {
  final bool success;
  String? failureMessage;

  CategoryCreatedEvent({required this.success, failureMessage});
}

class CategoryUpdatingEvent extends CategoryDataEvent {
  final String? failureMessage;
  final bool success;

  CategoryUpdatingEvent({required this.success, this.failureMessage});
}

class CategoryDeletionEvent extends CategoryDataEvent {
  final CategoryVo category;
  final int originalIndex;

  CategoryDeletionEvent(this.category, this.originalIndex);
}