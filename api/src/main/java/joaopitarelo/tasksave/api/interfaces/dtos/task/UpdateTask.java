package joaopitarelo.tasksave.api.interfaces.dtos.task;

import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;
import joaopitarelo.tasksave.api.infraestruture.security.validation.OptionalNotBlank;

import java.util.Date;

public record UpdateTask(
        @OptionalNotBlank
        String title,
        @OptionalNotBlank
        String description,
        Date deadline,
        Long categoryId,
        Priority priority,
        ReminderType reminderType,
        Long position
) { }
