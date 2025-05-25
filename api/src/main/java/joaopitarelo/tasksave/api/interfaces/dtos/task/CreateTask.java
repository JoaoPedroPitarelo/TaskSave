package joaopitarelo.tasksave.api.interfaces.dtos.task;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;
import org.springframework.format.annotation.DateTimeFormat;

import java.sql.Date;

public record CreateTask(
        @NotBlank
        String title,
        String description,
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        Date deadline,
        @NotNull
        @Valid // Mostra ao Validation que dentro desse meu Record que ele esta validando existe outro Record que ele precisa validar também. Como se fosse um "valide isso"
        Long categoryId,
        @NotNull // NotNull pois somente os campos do tipo texto podem ser anotados com NotBlank. E Sobre a validação do Enum o próprio spring faz isso para gente
        Priority priority,
        ReminderType reminderType
) { }
