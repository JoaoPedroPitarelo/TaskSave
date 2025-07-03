package joaopitarelo.tasksave.api.application.services;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.domain.exceptions.InvalidPositionException;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.infraestruture.persistence.SubTaskJpaRepository;
import joaopitarelo.tasksave.api.domain.subtask.Subtask;
import joaopitarelo.tasksave.api.interfaces.dtos.subtask.UpdateSubtask;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Stream;

@Service
public class SubtaskService {
    @Autowired
    private SubTaskJpaRepository subtaskRepository;

    public void create(Subtask subtask, User user) {
        LocalDateTime lastModification = LocalDateTime.now();

        Optional<Long> lastPosition = subtaskRepository.findMaxPositionByUserIdAndParentTaskIdAndCompletedFalse(user.getId(), subtask.getParentTask().getId());

        subtask.setPosition(lastPosition.map(aLong -> aLong + 1L).orElse(0L));
        subtask.setCompleted(false);
        subtask.setUser(user);
        subtask.setLastModification(lastModification);
        subtaskRepository.save(subtask);
    }

    public Subtask getById(Long subtaskId, Long userId) {
        return subtaskRepository.findByIdAndUserIdAndCompletedFalse(subtaskId, userId);
    }

    public void update(@Valid UpdateSubtask modifiedSubtask, Subtask subtask) {
        LocalDateTime lastModification = LocalDateTime.now();

        subtask.setTitle(modifiedSubtask.title() != null ? modifiedSubtask.title() : subtask.getTitle());
        subtask.setDescription(modifiedSubtask.description() != null ? modifiedSubtask.description() : subtask.getDescription());
        subtask.setLastModification(lastModification);
        subtask.setDeadline(modifiedSubtask.deadline() != null ? modifiedSubtask.deadline() : subtask.getDeadline());
        subtask.setPriority(modifiedSubtask.priority() != null ? modifiedSubtask.priority() : subtask.getPriority());
        subtask.setReminderType(modifiedSubtask.reminderType() != null ? modifiedSubtask.reminderType() : subtask.getReminderType());

        if (modifiedSubtask.position() != null) {
            Long oldPosition = subtask.getPosition();
            Long newPosition = modifiedSubtask.position();

            orderSubtaskListOnSubtaskList(oldPosition, newPosition, subtask);
        }

        subtaskRepository.save(subtask);
    }

    private void orderSubtaskListOnSubtaskList(Long oldPosition, Long newPosition, Subtask subtaskToReplace) {
        if(Objects.equals(oldPosition, newPosition)) {
            return;
        }

        if(!isValidPosition(newPosition,subtaskToReplace.getUser().getId(), subtaskToReplace.getParentTask().getId())) {
            throw new InvalidPositionException("invalid position");
        }

        Subtask subtaskOnDesiredPosition;
        Optional<Subtask> subtaskOnDesiredPositionOpt = subtaskRepository.findByUserIdAndParentTaskIdAndPositionAndCompletedFalse(
                subtaskToReplace.getUser().getId(),
                subtaskToReplace.getParentTask().getId(),
                newPosition
        );

        if (subtaskOnDesiredPositionOpt.isEmpty()) {
            throw new RuntimeException();
        }

        subtaskOnDesiredPosition = subtaskOnDesiredPositionOpt.get();
        subtaskOnDesiredPosition.setPosition(oldPosition);
        subtaskToReplace.setPosition(newPosition);

        subtaskRepository.save(subtaskOnDesiredPosition);
        subtaskRepository.save(subtaskToReplace);
    }

    private boolean isValidPosition(Long position, Long userId, Long parentTaskId) {
        int subtaskList = subtaskRepository.findByUserIdAndParentTaskIdAndCompletedFalse(userId, parentTaskId).size();

        if(position > subtaskList -1) {
            return false;
        }

        return position >= 0;
    }

    public void delete(Long id, Long userId) {
        Subtask subtask = subtaskRepository.findByIdAndUserIdAndCompletedFalse(id, userId);
        subtask.setCompleted(true);

        reorderPositionListAfterDelete(userId, subtask.getParentTask().getId(), subtask.getPosition());

        subtaskRepository.save(subtask);
    }

    private void reorderPositionListAfterDelete(Long userId, Long parentTaskId, Long deletedSubtaskPosition) {
        Stream<Subtask> subtaskList = subtaskRepository.findByUserIdAndParentTaskIdAndCompletedFalse(userId, parentTaskId).stream();

        List<Subtask> newOrdenedList = subtaskList
                .filter(subtask -> subtask.getPosition() > deletedSubtaskPosition)
                .peek(subtask -> subtask.setPosition(subtask.getPosition() -1L)).toList();

        subtaskRepository.saveAll(newOrdenedList);
    }
}
