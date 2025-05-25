package joaopitarelo.tasksave.api.application.services;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.infraestruture.persistence.SubTaskJpaRepository;
import joaopitarelo.tasksave.api.domain.subtask.Subtask;
import joaopitarelo.tasksave.api.interfaces.dtos.subtask.UpdateSubtask;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class SubtaskService {
    @Autowired
    private SubTaskJpaRepository subtaskRepository;

    // Create
    public void create(Subtask subtask, User user) {
        LocalDateTime lastModification = LocalDateTime.now();
        subtask.setCompleted(false);
        subtask.setUser(user);
        subtask.setLastModification(lastModification);
        subtaskRepository.save(subtask);
    }

    // GetById
    public Subtask getById(Long subtaskId, Long userId) {
        return subtaskRepository.findByIdAndUserIdAndCompletedFalse(subtaskId, userId);
    }

    // Update
    public void update(@Valid UpdateSubtask modifiedSubtask, Subtask subtask) {
        LocalDateTime lastModification = LocalDateTime.now();

        subtask.setTitle(modifiedSubtask.title() != null ? modifiedSubtask.title() : subtask.getTitle());
        subtask.setDescription(modifiedSubtask.description() != null ? modifiedSubtask.description() : subtask.getDescription());
        subtask.setLastModification(lastModification);
        subtask.setDeadline(modifiedSubtask.deadline() != null ? modifiedSubtask.deadline() : subtask.getDeadline());
        subtask.setPriority(modifiedSubtask.priority() != null ? modifiedSubtask.priority() : subtask.getPriority());
        subtask.setReminderType(modifiedSubtask.reminderType() != null ? modifiedSubtask.reminderType() : subtask.getReminderType());

        subtaskRepository.save(subtask);
    }

    // Delete
    public void delete(Long id, Long userId) {
        Subtask subtask = subtaskRepository.findByIdAndUserIdAndCompletedFalse(id, userId);
        subtask.setCompleted(true);

        subtaskRepository.save(subtask);
    }
}
