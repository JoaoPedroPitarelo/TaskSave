package joaopitarelo.tasksave.api.service;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.subtask.CreateSubTask;
import joaopitarelo.tasksave.api.dto.subtask.UpdateSubtask;
import joaopitarelo.tasksave.api.model.Subtask;
import joaopitarelo.tasksave.api.model.Task;
import joaopitarelo.tasksave.api.repository.SubTaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SubtaskService {
    @Autowired
    private SubTaskRepository subTaskRepository;

    // Create
    public void createSubtask(@Valid CreateSubTask subtask, Task task) {
        Subtask newSubTask = new Subtask(subtask, task);
        subTaskRepository.save(newSubTask);
    }

    // Update
    public void updateSubtask(@Valid UpdateSubtask modifiedSubtask) {
        Subtask subtask = subTaskRepository.getReferenceById(modifiedSubtask.id());

        subtask.setTitle(modifiedSubtask.title() != null ? modifiedSubtask.title() : subtask.getTitle());
        subtask.setDescription(modifiedSubtask.description() != null ? modifiedSubtask.description() : subtask.getDescription());
        subtask.setDeadline(modifiedSubtask.deadline() != null ? modifiedSubtask.deadline() : subtask.getDeadline());
        subtask.setLastModification(modifiedSubtask.lastModification());
        subtask.setPriority(modifiedSubtask.priority() != null ? modifiedSubtask.priority() : subtask.getPriority());
        subtask.setStatus(modifiedSubtask.status() != null ? modifiedSubtask.status() : subtask.getStatus());
        subtask.setReminderType(modifiedSubtask.reminderType() != null ? modifiedSubtask.reminderType() : subtask.getReminderType());

        subTaskRepository.save(subtask);
    }
}
