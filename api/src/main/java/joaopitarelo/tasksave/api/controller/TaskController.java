package joaopitarelo.tasksave.api.controller;

import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.task.OutputTask;
import joaopitarelo.tasksave.api.dto.task.UpdateTask;
import joaopitarelo.tasksave.api.model.Category;
import joaopitarelo.tasksave.api.model.Task;
import joaopitarelo.tasksave.api.service.CategoryService;
import joaopitarelo.tasksave.api.service.TaskService;
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

    // TODO delete  []

    @Autowired
    private TaskService taskService;
    @Autowired
    private CategoryService categoryService;

    // GetAll
    @GetMapping
    public ResponseEntity<List<OutputTask>> getAll() {
        return ResponseEntity.ok(taskService.getTasks().stream().map(OutputTask::new).toList());
    }

    // Create
    @PostMapping("/create")
    @Transactional
    public ResponseEntity<String> create(@RequestBody @Valid CreateTask taskDTO) {
        Category category = categoryService.getCategoryById(taskDTO.categoryId());
        if (category == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Categoria não encontrada");

        taskService.createTask(new Task(taskDTO, category));
        return ResponseEntity.status(HttpStatus.CREATED).body("Tarefa criada com sucesso");
    }

    // GetById
    @GetMapping("/{id}")
    public ResponseEntity<OutputTask> getById(@PathVariable Long id) {
        Task task = taskService.getTaskById(id);

        if (task != null) return ResponseEntity.ok(new OutputTask(task));

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
    }

    // Update
    @PutMapping
    @Transactional
    public ResponseEntity<String> update(@RequestBody @Valid UpdateTask modifiedTask) {
        taskService.updateTask(modifiedTask);
        return ResponseEntity.ok("Tarefa modificado"); // TODO melhorar esse retorno
    }

    // Delete
    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<String> delete(@PathVariable Long id) {
        taskService.deleteTask(id);
        return ResponseEntity.status(HttpStatus.OK).body("Tarefa remvida com sucesso");
    }

}
