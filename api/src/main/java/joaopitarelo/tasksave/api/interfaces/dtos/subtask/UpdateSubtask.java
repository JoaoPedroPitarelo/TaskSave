package joaopitarelo.tasksave.api.interfaces.dtos.subtask;

import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;

import java.util.Date;

public record UpdateSubtask(
        String title,
        String description,
        Date deadline,
        Priority priority,
        ReminderType reminderType
) { }
