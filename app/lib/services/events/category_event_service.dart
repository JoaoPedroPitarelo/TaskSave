import 'dart:async';
import 'package:app/domain/events/category_events.dart';

class CategoryEventService {
  static final CategoryEventService _instance = CategoryEventService._internal();

  CategoryEventService._internal();

  factory CategoryEventService() {
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