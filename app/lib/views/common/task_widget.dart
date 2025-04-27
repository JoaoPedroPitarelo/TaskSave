import 'package:app/models/category_vo.dart';
import 'package:app/models/enums/priority_enum.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// TODO melhorar isso aqui para produção, por enquanto este widget esta sendo somente para visualização
class TaskWidget extends StatelessWidget {
  final String title;
  final String description;
  final DateTime deadline;
  final PriorityEnum priority;
  final CategoryVo category;

  const TaskWidget({
    super.key,
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.category
  });

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
    return Container(
      decoration: BoxDecoration(
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
                color: getPriorityColor(priority.name),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 62, 62, 62),
                      borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: 24,
                              textStyle: TextStyle(inherit: false))),
                          SizedBox(height: 8),
                          Container(
                            width: 140,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color:Color.fromARGB(255, 44, 44, 44)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(Icons.date_range, color: Colors.white, size: 18),
                                  Text(DateFormat('dd/MM/yyyy').format(deadline), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, inherit: false)),
                                  Icon(Icons.alarm, color: Colors.white, size: 18,),   
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
                      color: Color.fromARGB(255, 42, 42, 42),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Text(
                      description,
                      style: GoogleFonts.roboto(color: Colors.white, fontSize: 15, textStyle: TextStyle(inherit: false)),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
