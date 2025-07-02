import 'dart:async';
import 'package:app/core/typedefs/typedefs.dart';
import 'package:app/repositories/category_repository.dart';
import 'package:app/services/events/category_event_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:app/domain/events/categoryEvents.dart';

class CategoryFormViewmodel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;
  final FailureMessageMapper _failureMessageMapper;
  final _categoryEventsService = CategoryEventservice();

  bool _loading = false;
  bool get isLoading => _loading;

  Object? _errorMessage;
  Object? get errorMessage => _errorMessage;

  CategoryFormViewmodel(this._failureMessageMapper ,this._categoryRepository);

  Future<void> saveCategory(String description, String hexColor) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _categoryRepository.create(description, hexColor);

    result.fold(
      (failure) {
        _errorMessage = _failureMessageMapper(failure);
        _categoryEventsService.add(CategoryCreatedEvent(
          success: false,
          failureMessage: _errorMessage.toString())
        );
        _loading = false;
        notifyListeners();
      },
      (categoryVo) {
        _loading = false;
        _categoryEventsService.add(CategoryCreatedEvent(
            success: true,
            failureMessage: _errorMessage.toString())
        );
        _categoryEventsService.add(CategoriesChangedEvent(isCreating: true));
        notifyListeners();
      }
    );
  }

  Future<void> updateCategory(String description, String hexColor, String categoryId) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _categoryRepository.update(
      id: categoryId,
      description: description,
      color: hexColor
    );

    result.fold(
      (failure) {
        _loading = false;
        _errorMessage = _failureMessageMapper(failure);
        _categoryEventsService.add(CategoryUpdatingEvent(
          success: false,
          failureMessage: _errorMessage.toString())
        );
        notifyListeners();
      },
      (updatedCategory) {
        _loading = false;
        _categoryEventsService.add(CategoryUpdatingEvent(
          success: true,
          failureMessage: _errorMessage.toString())
        );
        _categoryEventsService.add(CategoriesChangedEvent(isCreating: false));
        notifyListeners();
      }
    );
  }

  clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}

class CategoryCreateEvent {
  final String? failureMessage;
  bool success = false;

  CategoryCreateEvent({this.failureMessage, required this.success});
}
