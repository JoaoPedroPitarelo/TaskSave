package joaopitarelo.tasksave.api.dto.task;

import jakarta.validation.constraints.NotNull;
import joaopitarelo.tasksave.api.model.Priority;
import joaopitarelo.tasksave.api.model.ReminderType;
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
