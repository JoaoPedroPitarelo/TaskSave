package joaopitarelo.tasksave.api.application.services;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.domain.subtask.Subtask;
import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.domain.exceptions.CategoryNotFoundException;
import joaopitarelo.tasksave.api.domain.exceptions.InvalidPositionException;
import joaopitarelo.tasksave.api.infraestruture.persistence.TaskJpaRepository;
import joaopitarelo.tasksave.api.interfaces.dtos.task.UpdateTask;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.infraestruture.persistence.CategoryJpaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Stream;

@Service
public class TaskService {

    @Autowired
    private TaskJpaRepository taskRepository;
    @Autowired
    private CategoryJpaRepository categoryRepository;
    @Autowired
    private SubtaskService subtaskService;

    public List<Task> getAll(Long userId) {
        return taskRepository.findByCompletedFalseAndUserIdOrderByPosition(userId);
    }

    public List<Task> getByCategory(Long useId, Long categoryId) {
        return taskRepository.findByCompletedFalseAndUserIdAndCategoryId(useId, categoryId);
    }

    public void create(Task task, User user) {
        LocalDateTime lastModification = LocalDateTime.now();

        Optional<Long> lastPosition = taskRepository.findMaxPositionByUserAndCompletedFalse(user.getId());

        task.setPosition(lastPosition.map(aLong -> aLong + 1L).orElse(0L));
        task.setCompleted(false);
        task.setUser(user);
        task.setLastModification(lastModification);
        taskRepository.save(task);
    }

    public Task getById(Long idTask, Long userId) {
        return taskRepository.findByIdAndUserIdAndCompletedFalse(idTask, userId);
    }

    public void update(Task task, @Valid UpdateTask modifiedTask, Long categoryId) {
        LocalDateTime lastModification = LocalDateTime.now();
        Category category = null;

        if (categoryId != null) {
            Optional<Category> categoryOptional = categoryRepository.findByIdAndUserIdAndAtivoTrue(categoryId, task.getUser().getId());
            if (categoryOptional.isEmpty()) {
                throw new CategoryNotFoundException("category not found");
            }
            category = categoryOptional.get();
        }

        if(modifiedTask.position() != null) {
            Long oldPosition = task.getPosition();
            Long newPosition = modifiedTask.position();

            orderTaskOnTaskList(oldPosition, newPosition, task);
        }

        task.setTitle(modifiedTask.title() != null ? modifiedTask.title() : task.getTitle());
        task.setDescription(modifiedTask.description() != null ? (modifiedTask.description().isEmpty() ? null : modifiedTask.description()) : task.getDescription());
        task.setDeadline(modifiedTask.deadline() != null ? modifiedTask.deadline() : task.getDeadline());
        task.setLastModification(lastModification);
        task.setCategory(category != null ? category : task.getCategory());
        task.setPriority(modifiedTask.priority() != null ? modifiedTask.priority() : task.getPriority());
        task.setReminderType(modifiedTask.reminderType() != null ? modifiedTask.reminderType() : task.getReminderType());

        taskRepository.save(task);
    }

    private void orderTaskOnTaskList(Long oldPosition, Long newPosition, Task taskToReplace) {
        if (Objects.equals(oldPosition, newPosition)) {
            return;
        }

        if (!isAValidPosition(newPosition, taskToReplace.getUser().getId())) {
            throw new InvalidPositionException("Invalid position");
        }

        Task taskOnNewPosition;
        Task taskOnOldPosition;
        Optional<Task> taskOnNewPositionOpt = taskRepository.findByUserIdAndPositionAndCompletedFalse(taskToReplace.getUser().getId(), newPosition);
        Optional<Task> taskOnOldPositionOpt = taskRepository.findByUserIdAndPositionAndCompletedFalse(taskToReplace.getUser().getId(), oldPosition);

        if (taskOnNewPositionOpt.isEmpty() || taskOnOldPositionOpt.isEmpty()) {
            throw new RuntimeException("Task not found to be replaced");
        }

        if (Math.abs(oldPosition - newPosition) == 1) {
            taskOnNewPosition = taskOnNewPositionOpt.get();
            taskOnOldPosition = taskOnOldPositionOpt.get();

            taskOnOldPosition.setPosition(newPosition);
            taskOnNewPosition.setPosition(oldPosition);

            taskRepository.save(taskOnOldPosition);
            taskRepository.save(taskOnNewPosition);
            return;
        }

        if (Math.abs(oldPosition - newPosition) >= 2) {
            Stream<Task> taskList = taskRepository.findByCompletedFalseAndUserIdOrderByPosition(taskToReplace.getUser().getId()).stream();

            List<Task> newOrdenedList;

            if ((oldPosition - newPosition) < 0) {
                newOrdenedList = taskList
                        .filter(t -> t.getPosition() <= newPosition && !t.getPosition().equals(oldPosition) && t.getPosition() > 0)
                        .peek(t -> t.setPosition(t.getPosition() -1L)).toList();
            } else {
                newOrdenedList = taskList
                        .filter(t -> t.getPosition() >= newPosition && !t.getPosition().equals(oldPosition) && t.getPosition() < oldPosition)
                        .peek(t -> t.setPosition(t.getPosition() +1L)).toList();
            }

            taskToReplace.setPosition(newPosition);
            taskRepository.save(taskToReplace);

            taskRepository.saveAll(newOrdenedList);
        }
    }

    private boolean isAValidPosition(Long position, Long userId) {
        int taskListSize = taskRepository.findByCompletedFalseAndUserIdOrderByPosition(userId).size();

        if (position > taskListSize -1) {
            return false;
        }

        return position >= 0;
    }

    public void delete(Task task) {
        task.setCompleted(true);

        List<Subtask> subtaskList = subtaskService.getSubtasks(task.getUser().getId(), task.getId());

        if (!subtaskList.isEmpty()) {
            subtaskList.forEach(subtask -> subtaskService.delete(subtask.getId(), task.getUser().getId()));
        }

        reorderPositionListAfterDelete(task.getPosition(), task.getUser().getId());
        taskRepository.save(task);
    }

    private void reorderPositionListAfterDelete(Long deletedTaskPosition, Long userId) {
        Stream<Task> taskList = taskRepository.findByCompletedFalseAndUserIdOrderByPosition(userId).stream();

        List<Task> newOrdenedList = taskList
                .filter(task -> task.getPosition() > deletedTaskPosition)
                .peek(task -> task.setPosition(task.getPosition() -1L)).toList();

        taskRepository.saveAll(newOrdenedList);
    }

}
