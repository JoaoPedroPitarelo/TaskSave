package joaopitarelo.tasksave.api.interfaces.dtos.subtask;

import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;
import joaopitarelo.tasksave.api.domain.subtask.Subtask;

import java.time.LocalDateTime;
import java.util.Date;

public record OutputSubtask(
        Long id,
        String title,
        String description,
        Date deadline,
        LocalDateTime lastModification,
        Priority priority,
        boolean completed,
        ReminderType reminderType
) {
    public OutputSubtask(Subtask subtask) {
        this(subtask.getId(),
                subtask.getTitle(),
                subtask.getDescription(),
                subtask.getDeadline(),
                subtask.getLastModification(),
                subtask.getPriority(),
                subtask.isCompleted(),
                subtask.getReminderType()
        );
    }
}
