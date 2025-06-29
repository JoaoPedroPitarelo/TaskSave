package joaopitarelo.tasksave.api.application.services;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.infraestruture.persistence.TaskJpaRepository;
import joaopitarelo.tasksave.api.interfaces.dtos.task.UpdateTask;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.infraestruture.persistence.CategoryJpaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class TaskService {

    @Autowired
    private TaskJpaRepository taskRepository;
    @Autowired
    private CategoryJpaRepository categoryRepository;

    public List<Task> getTasks(Long userId) {
        return taskRepository.findByCompletedFalseAndUserId(userId);
    }

    public List<Task> getTaskByCategory(Long useId, Long categoryId) {
        return taskRepository.findByCompletedFalseAndUserIdAndCategoryId(useId, categoryId);
    }

    public void createTask(Task task, User user) {
        LocalDateTime lastModification = LocalDateTime.now();

        task.setCompleted(false);
        task.setUser(user);
        task.setLastModification(lastModification);
        taskRepository.save(task);
    }

    public Task getTaskById(Long idTask, Long userId) {
        return taskRepository.findByIdAndUserIdAndCompletedFalse(idTask, userId);
    }

    public void updateTask(Task task, @Valid UpdateTask modifiedTask, Category category) {
        LocalDateTime lastModification = LocalDateTime.now();

        task.setTitle(modifiedTask.title() != null ? modifiedTask.title() : task.getTitle());
        task.setDescription(modifiedTask.description() != null ? modifiedTask.description() : task.getDescription());
        task.setDeadline(modifiedTask.deadline() != null ? modifiedTask.deadline() : task.getDeadline());
        task.setLastModification(lastModification);
        task.setCategory(category != null ? category : task.getCategory());
        task.setPriority(modifiedTask.priority() != null ? modifiedTask.priority() : task.getPriority());
        task.setReminderType(modifiedTask.reminderType() != null ? modifiedTask.reminderType() : task.getReminderType());

        taskRepository.save(task);
    }

    // Delete
    public void deleteTask(Task task) {
        task.setCompleted(true);
        taskRepository.save(task);
    }
}
