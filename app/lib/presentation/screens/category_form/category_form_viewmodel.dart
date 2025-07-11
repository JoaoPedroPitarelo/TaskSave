import 'dart:async';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/repositories/category_repository.dart';
import 'package:app/services/events/category_event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:app/core/events/category_events.dart';


class CategoryFormViewmodel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;
  final _categoryEventsService = CategoryEventService();

  bool _loading = false;
  bool get isLoading => _loading;

  final FailureKey Function(Failure) _mapFailureToKey;
  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  CategoryFormViewmodel(this._mapFailureToKey ,this._categoryRepository);

  Future<void> saveCategory(String description, String hexColor) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _categoryRepository.create(description, hexColor);

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _categoryEventsService.add(CategoryCreatedEvent(
            success: false,
            failureKey: _errorKey
          )
        );
        _loading = false;
        notifyListeners();
      },
      (categoryVo) {
        _loading = false;
        _categoryEventsService.add(CategoryCreatedEvent(
            success: true,
            failureKey: _errorKey
          )
        );
        _categoryEventsService.add(CategoriesChangedEvent(isCreating: true));
        notifyListeners();
      }
    );
  }

  Future<void> updateCategory(String description, String hexColor, String categoryId) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _categoryRepository.update(
      id: categoryId,
      description: description,
      color: hexColor
    );

    result.fold(
      (failure) {
        _loading = false;
        _errorKey = _mapFailureToKey(failure);
        _categoryEventsService.add(CategoryUpdatingEvent(
            success: false,
            failureKey: _errorKey
          )
        );
        notifyListeners();
      },
      (updatedCategory) {
        _loading = false;
        _categoryEventsService.add(CategoryUpdatingEvent(success: true));
        _categoryEventsService.add(CategoriesChangedEvent(isCreating: false));
        notifyListeners();
      }
    );
  }

  clearErrorMessage() {
    _errorKey = null;
    notifyListeners();
  }
}

class CategoryCreateEvent {
  final String? failureMessage;
  bool success = false;

  CategoryCreateEvent({this.failureMessage, required this.success});
}
