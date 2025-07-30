import 'dart:async';
import 'package:task_save/presentation/screens/home/category_viewmodel.dart';
import 'package:task_save/presentation/screens/home/task_viewmodel.dart';
import 'package:flutter/material.dart';

class HomeViewmodel extends ChangeNotifier {
  final TaskViewmodel _taskViewmodel;
  final CategoryViewmodel _categoryViewmodel;

  HomeViewmodel(this._taskViewmodel, this._categoryViewmodel) {
    _taskViewmodel.addListener(notifyListeners);
    _categoryViewmodel.addListener(notifyListeners);
  }

  Future<void> getInitialData() async {
    await Future.wait([
      _taskViewmodel.getTasks(),
      _categoryViewmodel.getCategories(),
    ]);
  }

  @override
  void dispose() {
    _taskViewmodel.removeListener(notifyListeners);
    _categoryViewmodel.removeListener(notifyListeners);
    super.dispose();
  }

  void clearUserData() {
    _categoryViewmodel.clearData();
    _taskViewmodel.clearData();
    notifyListeners();
  }
}
