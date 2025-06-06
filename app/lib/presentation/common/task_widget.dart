import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class TaskWidget extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final PriorityEnum priority;
  final CategoryVo category;
  bool completed;
  VoidCallback? onDismissedCallback;

  // Construtor comum ou padrão
  TaskWidget({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.category,
    required this.completed,
    this.onDismissedCallback
  });

  TaskWidget.fromTaskVo(TaskVo task, {super.key, this.onDismissedCallback})
      : id = task.id,
        title = task.title,
        description = task.description != null ? task.description! : "",
        deadline = task.deadline,
        priority = task.priority,
        category = task.category,
        completed = task.completed;

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  
  final player = AudioPlayer();
  
  MaterialColor getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'NEUTRAL':
        return Colors.blue;
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.yellow;
      case 'HIGH':
        return Colors.red;
      default:
        // caso de algum erro ou coisa do tipo 
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(widget.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        // TODO fazer a regra de negócio para mandar a requisição para a API, e realmente marcar como completed no BD
        await player.play(AssetSource("sounds/taskCompleted.mp3"));
        print("Tarefa {$widget.title} completa");
        widget.completed = true;

        if (widget.onDismissedCallback != null) {
          widget.onDismissedCallback!();
        }
      },
      background: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: const Color.fromARGB(255, 0, 255, 8), size: 80),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 15,  spreadRadius: 1, offset: Offset(-4, 10))],
          color: Color.fromARGB(255, 96, 96, 96),
          borderRadius: BorderRadius.all(Radius.circular(20))),
        width: 320,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              Container(
                width: 30,
                decoration: BoxDecoration(
                  color: getPriorityColor(widget.priority.name),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255), // ------------------------
                        borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: theme.textTheme.labelMedium,
                            ), 
                            SizedBox(height: 8),
                            Container(
                              width: 140,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color:Color.fromARGB(255, 205, 205, 205)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.date_range,  
                                      size: 18
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(widget.deadline), 
                                      style: theme.textTheme.labelSmall
                                    ),
                                    Icon(
                                      Icons.alarm, size: 18,),   
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 205, 205, 205), // ----------------
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      padding: EdgeInsets.all(9),
                      child: Text(
                        widget.description,
                        style: theme.textTheme.labelSmall,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
