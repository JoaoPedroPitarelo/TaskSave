import 'package:app/domain/enums/reminder_type_num.dart';

abstract class Notifiable {
  String id;
  ReminderTypeNum? reminderType;
  DateTime? deadline;

  Notifiable(this.id ,this.reminderType, this.deadline);
}