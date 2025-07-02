import 'dart:async';
import 'package:app/domain/events/categoryEvents.dart';

class CategoryEventservice {
  static final CategoryEventservice _instance = CategoryEventservice._internal();

  CategoryEventservice._internal();

  factory CategoryEventservice() {
    return _instance;
  }

  final StreamController<CategoryDataEvent> _categoryEventsController = StreamController<CategoryDataEvent>.broadcast();
  Stream<CategoryDataEvent> get onCategoryChanged => _categoryEventsController.stream;

  void add(CategoryDataEvent event) {
    _categoryEventsController.add(event);
  }

  void dispose() {
    _categoryEventsController.close();
  }
}