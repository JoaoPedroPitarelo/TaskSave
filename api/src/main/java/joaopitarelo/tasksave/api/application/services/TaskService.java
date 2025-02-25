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

import java.util.List;

@Service
public class TaskService {

    @Autowired
    private TaskJpaRepository taskRepository;
    @Autowired
    private CategoryJpaRepository categoryRepository;

    // GetAll
    public List<Task> getTasks(Long userId) {
        return taskRepository.findByCompletedFalseAndUserId(userId);
    }

    // Create
    public void createTask(Task task, User user) {
        task.setCompleted(false);
        task.setUser(user);
        taskRepository.save(task);
    }

    // GetById
    public Task getTaskById(Long idTask, Long userId) {
        return taskRepository.findByIdAndUserIdAndCompletedFalse(idTask, userId);
    }

    // Métodu para atualizar a task vinda do APP como UpdateTask DTO
    public void updateTask(Task task, @Valid UpdateTask modifiedTask, Category category) {
        task.setTitle(modifiedTask.title() != null ? modifiedTask.title() : task.getTitle());
        task.setDescription(modifiedTask.description() != null ? modifiedTask.description() : task.getDescription());
        task.setDeadline(modifiedTask.deadline() != null ? modifiedTask.deadline() : task.getDeadline());
        task.setLastModification(modifiedTask.lastModification());
        task.setCategory(category);
        task.setPriority(modifiedTask.priority() != null ? modifiedTask.priority() : task.getPriority());
        task.setReminderType(modifiedTask.reminderType() != null ? modifiedTask.reminderType() : task.getReminderType());

        taskRepository.save(task);
    }

    // Delete
    public void deleteTask(Long id) {
        Task task = taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task não encontrada"));

        task.setCompleted(true);

        taskRepository.save(task);
    }
}
