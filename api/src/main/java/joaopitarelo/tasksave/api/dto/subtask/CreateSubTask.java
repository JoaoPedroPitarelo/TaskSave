package joaopitarelo.tasksave.api.dto.subtask;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import joaopitarelo.tasksave.api.model.Priority;
import joaopitarelo.tasksave.api.model.ReminderType;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

public record CreateSubTask (
        @Valid
        Long parentTaskId,
        @NotBlank
        String title,
        String description,
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        Date deadline,
        @NotNull
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        Date lastModification,
        @NotNull
        Priority priority,
        ReminderType reminderType
) { }
