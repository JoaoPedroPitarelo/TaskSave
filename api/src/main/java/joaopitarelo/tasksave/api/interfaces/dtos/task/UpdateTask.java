package joaopitarelo.tasksave.api.interfaces.dtos.task;

import jakarta.validation.constraints.NotNull;
import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

public record UpdateTask(
        String title,
        String description,
        Date deadline,
        @NotNull
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        Date lastModification,
        Long categoryId,
        Priority priority,
        ReminderType reminderType
) { }
