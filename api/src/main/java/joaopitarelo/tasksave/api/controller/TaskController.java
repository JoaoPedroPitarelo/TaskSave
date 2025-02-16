package joaopitarelo.tasksave.api.controller;

import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.task.OutputTask;
import joaopitarelo.tasksave.api.model.Category;
import joaopitarelo.tasksave.api.model.Subtask;
import joaopitarelo.tasksave.api.model.Task;
import joaopitarelo.tasksave.api.repository.CategoryRepository;
import joaopitarelo.tasksave.api.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import joaopitarelo.tasksave.api.dto.task.CreateTask;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("task")
public class TaskController {

    @Autowired // Faz a injeção de dependências
    private TaskRepository taskRepository;
    @Autowired
    private CategoryRepository categoryRepository;

    @GetMapping
    public ResponseEntity<List<OutputTask>> getAll() {
        return ResponseEntity.ok(taskRepository.findAll().stream().map(OutputTask::new).toList());
    }

    @PostMapping("/create")
    @Transactional // Diz que é uma transação
    public ResponseEntity<String> create(@RequestBody @Valid CreateTask task) {
        Category category = categoryRepository.findById(task.categoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Categoria não encontrada"));
        Task newTask = new Task(task, category);
        taskRepository.save(newTask);

        return ResponseEntity.status(HttpStatus.CREATED).body("Tarefa criada com sucesso");
    }
}
