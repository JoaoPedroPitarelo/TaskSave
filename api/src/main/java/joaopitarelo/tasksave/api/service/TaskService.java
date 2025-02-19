package joaopitarelo.tasksave.api.service;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.task.UpdateTask;
import joaopitarelo.tasksave.api.model.Category;
import joaopitarelo.tasksave.api.model.Task;
import joaopitarelo.tasksave.api.repository.CategoryRepository;
import joaopitarelo.tasksave.api.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TaskService {

    @Autowired
    private TaskRepository taskRepository;
    @Autowired
    private CategoryRepository categoryRepository;

    // GetAll
    public List<Task> getTasks() {
        return taskRepository.findByCompletedFalse();
    }

    // Create
    public void createTask(Task task) {
        task.setCompleted(false);
        taskRepository.save(task);
    }

    // GetById
    public Task getTaskById(Long idTask) {
        return taskRepository.findByIdAndCompletedFalse(idTask);
    }

    // Métodu para atualizar a task vinda do APP como UpdateTask DTO
    public void updateTask(@Valid UpdateTask modifiedTask) {
        Task task = taskRepository.getReferenceById(modifiedTask.id());

        task.setTitle(modifiedTask.title() != null ? modifiedTask.title() : task.getTitle());
        task.setDescription(modifiedTask.description() != null ? modifiedTask.description() : task.getDescription());
        task.setDeadline(modifiedTask.deadline() != null ? modifiedTask.deadline() : task.getDeadline());
        task.setLastModification(modifiedTask.lastModification());

        System.out.println(modifiedTask.categoryId());

        Category category = categoryRepository.findById(modifiedTask.categoryId())
                .orElseThrow(() -> new RuntimeException("Categoria não encontrada"));

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
