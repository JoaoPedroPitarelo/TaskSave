package joaopitarelo.tasksave.api.dto.task;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import joaopitarelo.tasksave.api.dto.category.CreateCategory;
import joaopitarelo.tasksave.api.model.Priority;
import joaopitarelo.tasksave.api.model.ReminderType;
import joaopitarelo.tasksave.api.model.Status;
import org.springframework.format.annotation.DateTimeFormat;

import java.sql.Date;

public record CreateTask(
        @NotBlank
        String title,
        String description,
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        Date deadline,
        @NotNull
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        Date lastModification,
        @NotNull
        @Valid // Mostra ao Validation que dentro desse meu Record que ele esta validando existe outro Record que ele precisa validar também. Como se fosse um "valide isso"
        Long categoryId,
        @NotNull // NotNull pois somente os campos do tipo texto podem ser anotados com NotBlank. E Sobre a validação do Enum o próprio spring faz isso para gente
        Priority priority,
        @NotNull
        Status status,
        ReminderType reminderType
) { }
