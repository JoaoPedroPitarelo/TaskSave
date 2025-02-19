package joaopitarelo.tasksave.api.dto.subtask;

import jakarta.validation.constraints.NotNull;
import joaopitarelo.tasksave.api.model.Priority;
import joaopitarelo.tasksave.api.model.ReminderType;
import joaopitarelo.tasksave.api.model.Status;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

public record UpdateSubtask(
        @NotNull
        Long id,
        String title,
        String description,
        Date deadline,
        @NotNull
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        Date lastModification,
        Priority priority,
        Status status,
        ReminderType reminderType
) { }
