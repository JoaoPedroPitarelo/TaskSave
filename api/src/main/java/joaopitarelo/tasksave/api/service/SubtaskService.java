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
    public void createSubtask(Subtask subtask) {
        subtask.setCompleted(false);
        subTaskRepository.save(subtask);
    }

    // GetById
    public Subtask getById(Long subtaskId) {
        return subTaskRepository.findByIdAndCompletedFalse(subtaskId);
    }

    // Update
    public void updateSubtask(@Valid UpdateSubtask modifiedSubtask, Subtask subtask) {
        subtask.setTitle(modifiedSubtask.title() != null ? modifiedSubtask.title() : subtask.getTitle());
        subtask.setDescription(modifiedSubtask.description() != null ? modifiedSubtask.description() : subtask.getDescription());
        subtask.setDeadline(modifiedSubtask.deadline() != null ? modifiedSubtask.deadline() : subtask.getDeadline());
        subtask.setLastModification(modifiedSubtask.lastModification());
        subtask.setPriority(modifiedSubtask.priority() != null ? modifiedSubtask.priority() : subtask.getPriority());
        subtask.setReminderType(modifiedSubtask.reminderType() != null ? modifiedSubtask.reminderType() : subtask.getReminderType());

        subTaskRepository.save(subtask);
    }

    // Delete
    public void deleteSubtask(Long id) {
        Subtask subtask = subTaskRepository.getReferenceById(id);
        subtask.setCompleted(true);

        subTaskRepository.save(subtask);
    }
}
