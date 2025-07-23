import 'dart:async';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/core/enums/filtering_task_mode_enum.dart';
import 'package:app/core/events/task_events.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/repositories/api/category_repository.dart';
import 'package:app/repositories/api/task_repository.dart';
import 'package:app/services/events/category_event_service.dart';
import 'package:app/services/events/task_event_service.dart';
import 'package:flutter/material.dart';
import 'package:app/core/events/category_events.dart';
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
        filterTasks(_filterMode);
        _taskEventService.add(GetTasksEvent(success: true));
        _loading = false;
        notifyListeners();
      }
    );
  }

  void prepareTaskForDeletion(TaskVo task) {
    final originalIndex = _filteredTasks.indexOf(task);
    if (originalIndex == -1)  return;

    _filteredTasks.removeAt(originalIndex);

    _taskEventService.add(TaskDeletionEvent(task, originalIndex));
    notifyListeners();
  }

  void undoDeletionTask(TaskVo task, int originalIndex) {
    if(!_filteredTasks.contains(task)) {
      _filteredTasks.insert(originalIndex.clamp(0, _filteredTasks.length), task);
      notifyListeners();
    }
  }

  Future<void> confirmDeletionTask(task, originalIndex) async {
    final result = await _taskRepository.delete(task);

    result.fold(
     (failure) {
        _errorKey = _mapFailureToKey(failure);
        _loading = false;
        undoDeletionTask(task, originalIndex);
        // TODO lançar um evento de exclusão de tarefas (nesse caso success = false)
        notifyListeners();
      },
      (noContent) {
        _tasks.remove(task);
        _calculateCountTasks();
        notifyListeners();
      }
    );
  }

  Future<void> reorderTask(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _filteredTasks.length) return;
    if (newIndex < 0 || newIndex > _filteredTasks.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final TaskVo item = _filteredTasks.removeAt(oldIndex);
    _filteredTasks.insert(newIndex, item);

    notifyListeners();

    final result = await _taskRepository.update(
        id: item.id.toString(),
        position: newIndex
    );

    result.fold(
      (failure) {
        _loading = false;
        _errorKey = _mapFailureToKey(failure);
        _taskEventService.add(TaskReorderEvent(success: false, failureKey: _errorKey));
        notifyListeners();
      },
      (updatedTask) {
        _taskEventService.add(TaskReorderEvent(success: true));
        notifyListeners();
      }
    );
  }

  String _searchQuery = '';

  void searchTask(String query) {
    _searchQuery = query.trim();
    filterTasks(_filterMode);
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      return;
    }

    final searchTerms = _searchQuery.toLowerCase().split(' ').where((term) => term.isNotEmpty).toList();

    if (searchTerms.isEmpty) {
      return;
    }

    _filteredTasks = _filteredTasks.where((task) {
      final taskContent = [
        task.title.toLowerCase(),
        task.description?.toLowerCase() ?? '',
        task.category.description.toLowerCase(),
        ...task.subtaskList.map((s) => s.title.toLowerCase())
      ].join(' ');

      return searchTerms.every((term) => taskContent.contains(term));
    }).toList();
  }

  void _calculateCountTasks() {
    _countAllTasks = _tasks.length;
    _countTodayTasks = _filteredTasks.where((task) => (task.deadline as DateTime).isToday).length;
    _countNextWeekTasks = _filteredTasks.where((task) => (task.deadline as DateTime).isNextWeek).length;
    _countNextMonthTasks = _filteredTasks.where((task) => (task.deadline as DateTime).isNextMonth).length;
    _overdueTasks = _filteredTasks.where((task) => DateTime.now().isOverdue(task.deadline as DateTime)).length;
  }

  void filterTasks(FilteringTaskModeEnum filterMode) {
    _filterMode = filterMode;
    if (filterMode != FilteringTaskModeEnum.category) { _selectedCategory = null; }

    List<dynamic> tasks = List.from(_tasks);

    switch (filterMode) {
      case FilteringTaskModeEnum.all:
        break;
      case FilteringTaskModeEnum.today:
        tasks = tasks.where((task) => (task.deadline as DateTime).isToday).toList();
        break;
      case FilteringTaskModeEnum.nextWeek:
        tasks = tasks.where((task) => (task.deadline as DateTime).isNextWeek).toList();
        break;
      case FilteringTaskModeEnum.nextMonth:
        tasks = tasks.where((task) => (task.deadline as DateTime).isNextMonth).toList();
        break;
      case FilteringTaskModeEnum.overdue:
        tasks = tasks.where((task) => DateTime.now().isOverdue(task.deadline as DateTime)).toList();
        break;
      case FilteringTaskModeEnum.category:
        if (_selectedCategory != null) {
          tasks = tasks.where((task) => task.category.id == _selectedCategory!.id).toList();
        }
        break;
    }
    _filteredTasks = tasks;
    _applySearchFilter();
    notifyListeners();
  }

  void clearAllFiltersForTasks() {
    _selectedCategory = null;
    filterTasks(FilteringTaskModeEnum.all);
  }

  // Category ------------------------------------------------------------------
  void prepareCategoryForDeletion(CategoryVo category) {
    final originalIndex = _categories.indexOf(category);
    if (originalIndex == -1) return;

    _categories.removeAt(originalIndex);

    if (_selectedCategory != null && _selectedCategory!.id == category.id) {
      clearSelectedCategory();
      _deletedSelectedCategory = category;
    }

    _categoryEventsService.add(CategoryDeletionEvent(category, originalIndex));
    notifyListeners();
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
      _categories.insert(originalIndex.clamp(0, _categories.length), category);

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
