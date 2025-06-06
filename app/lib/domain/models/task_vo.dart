import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/enums/reminder_type_num.dart';
import 'package:app/domain/models/subtask_vo.dart';

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

  // TODO terminar essa parada, ela será essencial com a integração com o banco de dados
  factory TaskVo.fromJson(Map<String, dynamic> json) { 
    return TaskVo(
      id: json['id'], 
      title: json['title'], 
      deadline: json['deadline'], 
      priority: json['priority'], 
      category: CategoryVo(
        id: json['category']['id'], 
        description: json['category']['description'], 
        color: json['category']['color'],
        activate: json['category']['ativo']), 
      subtaskList: json['subtasks'],
      reminderType: json['reminderType'],
      completed: json['completed'],
    );     
  }
}
