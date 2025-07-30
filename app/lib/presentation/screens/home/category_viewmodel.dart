import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/core/events/category_events.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/repositories/api/category_repository.dart';
import 'package:app/services/events/category_event_service.dart';
import 'package:flutter/cupertino.dart';

class CategoryViewmodel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;
  final CategoryEventService _categoryEventsService = CategoryEventService();

  final FailureKey Function(Failure) _mapFailureToKey;
  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  List<dynamic> _categories = [];
  List<dynamic> get categories => _categories;

  bool _loading = false;
  bool get loading => _loading;

  CategoryVo? selectedCategory;
  CategoryVo? deletedSelectedCategory;

  CategoryViewmodel(
    this._categoryRepository,
    this._mapFailureToKey
  );

  Future<void> getCategories() async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _categoryRepository.getAll();

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
    if (originalIndex == -1) return;

    _categories.removeAt(originalIndex);

    if (selectedCategory != null && selectedCategory!.id == category.id) {
      clearSelectedCategory();
      deletedSelectedCategory = category;
    }

    _categoryEventsService.add(CategoryPrepareDeletionEvent(category, originalIndex));
    notifyListeners();
  }

  Future<void> confirmDeletionCategory(CategoryVo category, originalIndex) async {
    final result = await _categoryRepository.delete(category.id.toString());

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _loading = false;
        _categoryEventsService.add(CategoryDeletionEvent(success: false, failureKey: _errorKey));
        undoDeletionCategory(category, originalIndex);
        notifyListeners();
      },
      (noContent) {
        notifyListeners();
        _categoryEventsService.add(CategoryDeletionEvent(success: true));
      }
    );
  }

  void undoDeletionCategory(CategoryVo category, int originalIndex) {
    if (!_categories.contains(category)) {
      _categories.insert(originalIndex.clamp(0, _categories.length), category);

      if (deletedSelectedCategory != null && deletedSelectedCategory!.id == category.id) {
        selectedCategory = category;
        deletedSelectedCategory = null;
      }

      notifyListeners();
    }
  }

  Future<void> reorderCategory(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _categories.length) return;
    if (newIndex < 0 || newIndex > _categories.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final CategoryVo item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);

    notifyListeners();

    final result = await _categoryRepository.update(
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

  void selectCategory(CategoryVo category) {
    selectedCategory = category;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorKey = null;
    notifyListeners();
  }

  void clearSelectedCategory() {
    selectedCategory = null;
    notifyListeners();
  }

  void clearData() {
    _categories = [];
    _loading = false;
    _errorKey = null;
    selectedCategory = null;
    notifyListeners();
  }
}
