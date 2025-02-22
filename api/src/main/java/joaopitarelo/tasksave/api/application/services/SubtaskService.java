package joaopitarelo.tasksave.api.application.services;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.infraestruture.persistence.SubTaskJpaRepository;
import joaopitarelo.tasksave.api.domain.subtask.Subtask;
import joaopitarelo.tasksave.api.interfaces.dtos.subtask.UpdateSubtask;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SubtaskService {
    @Autowired
    private SubTaskJpaRepository subtaskRepository;

    // Create
    public void createSubtask(Subtask subtask) {
        subtask.setCompleted(false);
        subtaskRepository.save(subtask);
    }

    // GetById
    public Subtask getById(Long subtaskId) {
        return subtaskRepository.findByIdAndCompletedFalse(subtaskId);
    }

    // Update
    public void updateSubtask(@Valid UpdateSubtask modifiedSubtask, Subtask subtask) {
        subtask.setTitle(modifiedSubtask.title() != null ? modifiedSubtask.title() : subtask.getTitle());
        subtask.setDescription(modifiedSubtask.description() != null ? modifiedSubtask.description() : subtask.getDescription());
        subtask.setDeadline(modifiedSubtask.deadline() != null ? modifiedSubtask.deadline() : subtask.getDeadline());
        subtask.setLastModification(modifiedSubtask.lastModification());
        subtask.setPriority(modifiedSubtask.priority() != null ? modifiedSubtask.priority() : subtask.getPriority());
        subtask.setReminderType(modifiedSubtask.reminderType() != null ? modifiedSubtask.reminderType() : subtask.getReminderType());

        subtaskRepository.save(subtask);
    }

    // Delete
    public void deleteSubtask(Long id) {
        Subtask subtask = subtaskRepository.getReferenceById(id);
        subtask.setCompleted(true);

        subtaskRepository.save(subtask);
    }
}
