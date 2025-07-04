import 'dart:async';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/repositories/category_repository.dart';
import 'package:app/services/events/category_event_service.dart';
import 'package:flutter/material.dart';
import 'package:app/domain/events/category_events.dart';

class HomeViewmodel extends ChangeNotifier {
  final CategoryRepository categoryRepository;
  final CategoryEventService _categoryEventsService = CategoryEventService();

  final FailureKey Function(Failure) _mapFailureToKey;
  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  List<dynamic> _categories = [];
  List<dynamic> get categories => _categories;

  List<TaskVo> _tasks = [];
  List<TaskVo> get tasks => _tasks;

  CategoryVo? _selectedCategory;
  CategoryVo? _deletedSelectedCategory;
  CategoryVo? get selectedCategory => _selectedCategory;

  bool _loading = false;
  bool get loading => _loading;

  HomeViewmodel(
    this.categoryRepository,
    this._mapFailureToKey,
  );

  Future<void> getCategories() async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await categoryRepository.getAll();

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _loading = false;
        notifyListeners();
      },
      (categories) {
        _categories = categories['categories'].map((category) => CategoryVo.fromJson(category)).toList();
        _loading = false;
        notifyListeners();
      }
    );
  }

  void prepareCategoryForDeletion(CategoryVo category) {
    final originalIndex = _categories.indexOf(category);
    if (originalIndex == -1)  return;

    _categories.removeAt(originalIndex);

    if (_selectedCategory != null && _selectedCategory!.id == category.id) {
      clearSelectedCategory();
      _deletedSelectedCategory = category;
    }

    notifyListeners();

    _categoryEventsService.add(CategoryDeletionEvent(category, originalIndex));
  }

  Future<void> confirmDeletionCategory(category, originalIndex) async {
    final result = await categoryRepository.delete(category.id.toString());

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _loading = false;
        undoDeletionCategory(category, originalIndex);
        notifyListeners();
      },
      (noContent) {
        notifyListeners();
      }
    );
  }

  void undoDeletionCategory(CategoryVo category, int originalIndex) {
    if (!_categories.contains(category)) {
      _categories.insert(originalIndex.clamp(0,_categories.length), category);

      if (_deletedSelectedCategory != null && _deletedSelectedCategory!.id == category.id) {
        _selectedCategory = category;
        _deletedSelectedCategory = null;
      }

      notifyListeners();
    }
  }

  void selectCategory(CategoryVo category) {
    if (category.description == 'Default') {
      _selectedCategory = null;
      notifyListeners();
      return;
    }
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _categories.length) return;
    if (newIndex < 0 || newIndex > _categories.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final CategoryVo item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);

    notifyListeners();

    final result = await categoryRepository.update(
        id: item.id.toString(),
        position: newIndex
    );

    result.fold(
      (failure) {
        _loading = false;
        _errorKey = _mapFailureToKey(failure);
        _categoryEventsService.add(CategoryReorderEvent(success: false, failureKey: _errorKey));
        notifyListeners();
      },
      (updatedCategory) {
        _categoryEventsService.add(CategoryReorderEvent(success: true));
        notifyListeners();
      }
    );
  }

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorKey = null;
    notifyListeners();
  }
}
