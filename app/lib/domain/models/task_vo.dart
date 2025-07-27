import 'package:app/domain/models/attachmentVo.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/enums/reminder_type_num.dart';
import 'package:app/domain/models/notifiable.dart';
import 'package:app/domain/models/subtask_vo.dart';

class TaskVo extends Notifiable {
  final String title;
  final String? description;
  final PriorityEnum priority;
  final CategoryVo category;
  final List<SubtaskVo> subtaskList;
  List<AttachmentVo> attachmentList;
  bool completed;

  TaskVo({
    required id,
    required this.title,
    this.description,
    required deadline,
    required this.priority,
    required this.category,
    reminderType,
    required this.subtaskList,
    required this.attachmentList,
    required this.completed,
  }) : super(id, reminderType, deadline);

  factory TaskVo.fromJson(Map<String, dynamic> json) { 

    final subTasksList = (json['subtasks'] as List)
        .map((subtaskJson) => SubtaskVo.fromJson(subtaskJson))
        .toList();

    final attachmentList = (json['attachments'] as List)
        .map((attachmentJson) => AttachmentVo.fromJson(attachmentJson))
        .toList();

    final TaskVo task = TaskVo(
      id: json['id'].toString(),
      title: json['title'], 
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      priority: PriorityEnum.values.firstWhere((priority) => priority.name == json['priority'].toString().toLowerCase()),
      category: CategoryVo.fromJson(json['category']),
      subtaskList: subTasksList,
      attachmentList: attachmentList,
      reminderType: json['reminderType'] != null
          ? ReminderTypeNum.values.firstWhere((reminder) => reminder.name == json['reminderType'].toString().toLowerCase())
          : null,
      completed: json['completed'],
    );

    return task;
  }
}
