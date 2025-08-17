package joaopitarelo.tasksave.api.interfaces.dtos.subtask;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

public record CreateSubTask (
        @Valid
        @NotNull
        Long parentTaskId,
        @NotBlank
        String title,
        String description,
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        Date deadline,
        @NotNull
        Priority priority,
        ReminderType reminderType
) { }
