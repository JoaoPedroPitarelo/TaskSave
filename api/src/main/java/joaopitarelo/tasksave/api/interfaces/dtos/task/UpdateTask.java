package joaopitarelo.tasksave.api.interfaces.dtos.task;

import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;

import java.util.Date;

public record UpdateTask(
        String title,
        String description,
        Date deadline,
        Long categoryId,
        Priority priority,
        ReminderType reminderType
) { }
