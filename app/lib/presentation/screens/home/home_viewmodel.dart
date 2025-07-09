import 'dart:async';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/domain/enums/filtering_task_mode_enum.dart';
import 'package:app/domain/events/task_events.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/repositories/category_repository.dart';
import 'package:app/repositories/task_repository.dart';
import 'package:app/services/events/category_event_service.dart';
import 'package:app/services/events/task_event_service.dart';
import 'package:flutter/material.dart';
import 'package:app/domain/events/category_events.dart';
import 'package:app/core/utils/date_utils.dart';

class HomeViewmodel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;
  final TaskRepository _taskRepository;

  final CategoryEventService _categoryEventsService = CategoryEventService();
  final TaskEventService _taskEventService = TaskEventService();

  final FailureKey Function(Failure) _mapFailureToKey;
  FailureKey? _errorKey;
  FailureKey? get errorKey => _errorKey;

  List<dynamic> _categories = [];
  List<dynamic> get categories => _categories;

  List<dynamic> _tasks = [];
  List<dynamic> get tasks => _tasks;

  List<dynamic> _filteredTasks = [];
  List<dynamic> get filteredTasks => _filteredTasks;

  FilteringTaskModeEnum _filterMode = FilteringTaskModeEnum.all;
  FilteringTaskModeEnum get filterMode => _filterMode;

  CategoryVo? _selectedCategory;
  CategoryVo? _deletedSelectedCategory;
  CategoryVo? get selectedCategory => _selectedCategory;

  bool _loading = false;
  bool get loading => _loading;

  int _countAllTasks = 0;
  int _countTodayTasks = 0;
  int _countNextWeekTasks = 0;
  int _countNextMonthTasks = 0;
  int _overdueTasks = 0;

  int get countAllTasks => _countAllTasks;
  int get countTodayTasks => _countTodayTasks;
  int get countNextWeekTasks => _countNextWeekTasks;
  int get countNextMonthTasks => _countNextMonthTasks;
  int get countOverdueTasks => _overdueTasks;

  HomeViewmodel(
    this._categoryRepository,
    this._taskRepository,
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

  // Tasks ---------------------------------------------------------------------
  Future<void> getTasks() async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _taskRepository.getAll();

    result.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _taskEventService.add(GetTasksEvent(success: false, failureKey: _errorKey));
        _loading = false;
        notifyListeners();
      },
      (tasks) {
        _tasks = tasks['tasks'].map((task) => TaskVo.fromJson(task)).toList();
        _filteredTasks = _tasks;
        _calculateCountTasks();
        _taskEventService.add(GetTasksEvent(success: true));
        _loading = false;
        notifyListeners();
      }
    );
  }

  void _calculateCountTasks() {
    _countAllTasks = _tasks.length;
    _countTodayTasks = _filteredTasks.where((task) => (task.deadline as DateTime).isToday).length;
    _countNextWeekTasks = _filteredTasks.where((task) => (task.deadline as DateTime).isNextWeek).length;
    _countNextMonthTasks = _filteredTasks.where((task) => (task.deadline as DateTime).isNextMonth).length;
    _overdueTasks = _filteredTasks.where((task) => DateTime.now().isOverdue(task.deadline as DateTime)).length;
  }

  void filterTodayTasks() {
    _filteredTasks = _tasks.where((task) => (task.deadline as DateTime).isToday).toList();
    _selectedCategory = null;
    _filterMode = FilteringTaskModeEnum.today;
    notifyListeners();
  }

  void filterNextWeekTasks() {
    _filteredTasks = _tasks.where((task) => (task.deadline as DateTime).isNextWeek).toList();
    _selectedCategory = null;
    _filterMode = FilteringTaskModeEnum.nextWeek;
    notifyListeners();
  }

  void filterNextMonthTasks() {
    _filteredTasks = _tasks.where((task) => (task.deadline as DateTime).isNextMonth).toList();
    _selectedCategory = null;
    _filterMode = FilteringTaskModeEnum.nextMonth;
    notifyListeners();
  }

  void filterOverdueTasks() {
    _filteredTasks = _tasks.where((task) => DateTime.now().isOverdue(task.deadline as DateTime)).toList();
    _selectedCategory = null;
    _filterMode = FilteringTaskModeEnum.overdue;
    notifyListeners();
  }

  void filterTasksByCategory(CategoryVo? category) {
    _filteredTasks = _tasks.where((task) => task.category.id == category!.id).toList();
    _filterMode = FilteringTaskModeEnum.category;
    notifyListeners();
  }

  void clearAllFiltersForTasks() {
    _filteredTasks = _tasks;
    _selectedCategory = null;
    _filterMode = FilteringTaskModeEnum.all;
    notifyListeners();
  }

  // Category ------------------------------------------------------------------
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
    final result = await _categoryRepository.delete(category.id.toString());

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

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorKey = null;
    notifyListeners();
  }

  void clearUserData() {
    _categories = [];
    _tasks = [];
    _filterMode = FilteringTaskModeEnum.all;
    _selectedCategory = null;
    _loading = false;
    _countAllTasks = 0;
    _countTodayTasks = 0;
    _countNextWeekTasks = 0;
    _countNextMonthTasks = 0;
    _overdueTasks = 0;
    _filteredTasks = [];
    notifyListeners();
  }
}
