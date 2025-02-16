package joaopitarelo.tasksave.api.dto.subtask;

import joaopitarelo.tasksave.api.model.*;

import java.util.Date;

public record OutputSubtask(
        Long id,
        String title,
        String description,
        Date deadline,
        Date lastModification,
        Priority priority,
        Status status,
        ReminderType reminderType
) {
    public OutputSubtask(Subtask subtask) {
        this(subtask.getId(),
                subtask.getTitle(),
                subtask.getDescription(),
                subtask.getDeadline(),
                subtask.getLastModification(),
                subtask.getPriority(),
                subtask.getStatus(),
                subtask.getReminderType()
        );
    }
}
