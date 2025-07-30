import 'package:task_save/domain/enums/priority_enum.dart';
import 'package:task_save/domain/enums/reminder_type_num.dart';
import 'package:task_save/domain/models/notifiable.dart';

class SubtaskVo extends Notifiable {
  final String title;
  final String? description;
  final PriorityEnum priority;
  bool completed;

  SubtaskVo({
    required String id,
    required this.title,
    this.description,
    required deadline,
    required this.priority,
    required reminderType,
    required this.completed
  }) : super(id, reminderType, deadline);

  factory SubtaskVo.fromJson(Map<String, dynamic> json) {
    return SubtaskVo(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      priority: PriorityEnum.values.firstWhere((priority) => priority.name == json['priority'].toString().toLowerCase()),
      reminderType: json['reminderType'] != null
        ? ReminderTypeNum.values.firstWhere((reminderType) => reminderType.name == json['reminderType'].toString().toLowerCase())
        : null,
      completed: json['completed'],
    );
  }

}