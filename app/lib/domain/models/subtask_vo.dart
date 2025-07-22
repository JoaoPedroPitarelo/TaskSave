import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/enums/reminder_type_num.dart';

class SubtaskVo {
  final String id;
  final String title;
  final String? description;
  final DateTime deadline;
  final PriorityEnum priority;
  final ReminderTypeNum? reminderType;
  bool completed;

  SubtaskVo({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.priority,
    required this.reminderType,
    required this.completed
  });

  factory SubtaskVo.fromJson(Map<String, dynamic> json) {
    return SubtaskVo(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      priority: PriorityEnum.values.firstWhere((priority) => priority.name == json['priority'].toString().toLowerCase()),
      reminderType: json['reminderType'] != null
        ? ReminderTypeNum.values.firstWhere((reminderType) => reminderType.name == json['reminderType'].toString().toLowerCase())
        : null,
      completed: json['completed'],
    );
  }

}