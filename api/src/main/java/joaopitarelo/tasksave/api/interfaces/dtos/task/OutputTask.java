package joaopitarelo.tasksave.api.interfaces.dtos.task;

import joaopitarelo.tasksave.api.domain.attachment.Attachment;
import joaopitarelo.tasksave.api.interfaces.dtos.attachment.OutputAttachment;
import joaopitarelo.tasksave.api.interfaces.dtos.category.OutputCategory;
import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;
import joaopitarelo.tasksave.api.interfaces.dtos.subtask.OutputSubtask;
import joaopitarelo.tasksave.api.domain.task.Task;

import java.util.Date;
import java.util.List;

public record OutputTask(
        Long id,
        String title,
        String description,
        Date deadline,
        Date lastModification,
        OutputCategory category,
        Priority priority,
        boolean completed,
        ReminderType reminderType,
        List<OutputAttachment> attachments,
        List<OutputSubtask> subtasks
) {
    public OutputTask(Task task) {
        this(task.getId(),
                task.getTitle(),
                task.getDescription(),
                task.getDeadline(),
                task.getLastModification(),
                new OutputCategory(task.getCategory()),
                task.getPriority(),
                task.isCompleted(),
                task.getReminderType(),
                task.getAttachments() != null
                        ? task.getAttachments().stream()
                                .filter(Attachment::isAtivo)
                                .map(OutputAttachment::new)
                                .toList()
                        : List.of(),
                task.getSubtasks() != null
                        ? task.getSubtasks().stream()
                            .filter(subtask -> !subtask.isCompleted())
                            .map(OutputSubtask::new)
                            .toList()
                        : List.of() // senão retornar uma lista vazia
        );
    }
}
