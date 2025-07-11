import 'package:app/domain/models/task_vo.dart';
import 'package:flutter/material.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskVo task;

  const TaskDetailsScreen({required this.task, super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
    );
  }
}
