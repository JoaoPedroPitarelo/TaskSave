import 'package:app/models/enums/priority_enum.dart';
import 'package:app/models/enums/reminder_type_num.dart';
import 'package:app/models/task_vo.dart';

class SubtaskVo {
  // Atributos
  final String id;
  final TaskVo parentTask;
  final String title;
  final String? description;
  final DateTime deadline;
  final PriorityEnum priority;
  final ReminderTypeNum reminderType;
  final bool completed;

  // Construtor
  const SubtaskVo({
    required this.id,
    required this.parentTask,
    required this.title,
    this.description,
    required this.deadline,
    required this.priority,
    required this.reminderType,
    required this.completed
  });

  // Não precisa do fromJson

}