import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/enums/reminder_type_num.dart';
import 'package:app/domain/models/subtask_vo.dart';
import 'package:intl/date_time_patterns.dart';

class TaskVo {

  // Atributos  
  final String id;
  final String title;
  final String? description;
  final DateTime deadline;
  final PriorityEnum priority;
  final CategoryVo category;
  final ReminderTypeNum? reminderType;
  final List<SubtaskVo> subtaskList;
  final bool completed;

  // Construtor
  const TaskVo({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.priority,
    required this.category,
    required this.reminderType,
    required this.subtaskList,
    required this.completed,
  });

  factory TaskVo.fromJson(Map<String, dynamic> json) { 

    final subtasks = (json['subtasks'] as List)
        .map((subtaskJson) => SubtaskVo.fromJson(subtaskJson))
        .toList();

    return TaskVo(
      id: json['id'].toString(),
      title: json['title'], 
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      priority: PriorityEnum.values.firstWhere((priority) => priority.name == json['priority'].toString().toLowerCase()),
      category: CategoryVo.fromJson(json['category']),
      subtaskList: subtasks,
      reminderType: json['reminderType'] != null 
          ? ReminderTypeNum.values.firstWhere((reminder) => reminder.name == json['reminderType'].toString().toLowerCase())
          : null,
      completed: json['completed'],
    );     
  }
}
