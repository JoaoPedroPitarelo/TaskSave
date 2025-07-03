package joaopitarelo.tasksave.api.interfaces.dtos.subtask;

import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;
import joaopitarelo.tasksave.api.infraestruture.security.validation.OptionalNotBlank;

import java.util.Date;

public record UpdateSubtask(
        @OptionalNotBlank
        String title,
        @OptionalNotBlank
        String description,
        Date deadline,
        Priority priority,
        ReminderType reminderType,
        Long position
) { }
