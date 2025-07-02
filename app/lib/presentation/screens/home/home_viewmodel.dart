import 'dart:async';
import 'package:app/core/typedefs/typedefs.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/repositories/category_repository.dart';
import 'package:app/services/events/category_event_service.dart';
import 'package:flutter/material.dart';
import 'package:app/domain/events/categoryEvents.dart';

class HomeViewmodel extends ChangeNotifier {
  final CategoryRepository categoryRepository;
  // final TaskRepository taskRepository;
  final FailureMessageMapper _failureMessageMapper;
  final CategoryEventservice _categoryEventsService = CategoryEventservice();

  List<dynamic> _categories = [];
  List<dynamic> get categories => _categories;

  List<TaskVo> _tasks = [];
  List<TaskVo> get tasks => _tasks;

  CategoryVo? _selectedCategory;
  CategoryVo? _deletedSelectedCategory;
  CategoryVo? get selectedCategory => _selectedCategory;

  bool _loading = false;
  bool get loading => _loading;

  Object? _errorMessage;
  Object? get errorMessage => _errorMessage;

  HomeViewmodel(
    this.categoryRepository,
    // this.taskRepository,
    this._failureMessageMapper
  );

  Future<void> getCategories() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await categoryRepository.getAll();

    result.fold(
      (failure) {
        _errorMessage = _failureMessageMapper(failure);
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
        _errorMessage = _failureMessageMapper(failure);
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

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }


  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
