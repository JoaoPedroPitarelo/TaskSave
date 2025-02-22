package joaopitarelo.tasksave.api.controller;


import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.subtask.CreateSubTask;
import joaopitarelo.tasksave.api.dto.subtask.OutputSubtask;
import joaopitarelo.tasksave.api.dto.subtask.UpdateSubtask;
import joaopitarelo.tasksave.api.dto.task.OutputTask;
import joaopitarelo.tasksave.api.model.Subtask;
import joaopitarelo.tasksave.api.model.Task;
import joaopitarelo.tasksave.api.repository.SubTaskRepository;
import joaopitarelo.tasksave.api.repository.TaskRepository;
import joaopitarelo.tasksave.api.service.SubtaskService;
import joaopitarelo.tasksave.api.service.TaskService;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.util.UriComponentsBuilder;

@RestController
@RequestMapping("subtask")
public class SubTaskController {

    @Autowired
    private SubtaskService subtaskService;
    @Autowired
    private TaskService taskService;


    // GetById --------------------------------------
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id) {
        Subtask subtask = subtaskService.getById(id);

        if (subtask == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Subtask  not found");

        return ResponseEntity.ok(new OutputSubtask(subtask));
    }


    // Create ----------------------------------------
    @PostMapping("/create")
    public ResponseEntity<?> create(@RequestBody @Valid CreateSubTask newSubtask, UriComponentsBuilder uriBuilder) {
        Task task = taskService.getTaskById(newSubtask.parentTaskId());
        if (task == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Parent Task not found");

        Subtask subtask = new Subtask(newSubtask, task);
        subtaskService.createSubtask(subtask);

        var uri = uriBuilder.path("/subtask/{id}").buildAndExpand(subtask.getId()).toUri();

        return ResponseEntity.created(uri).body(new OutputSubtask(subtask));
    }

    // Update ----------------------------------------
    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<?> update(@RequestBody @Valid UpdateSubtask modifiedSubtask, @PathVariable Long id) {
        Subtask subtask = subtaskService.getById(id);
        if (subtask == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Subtask not found");

        subtaskService.updateSubtask(modifiedSubtask, subtask);
        return ResponseEntity.ok(new OutputSubtask(subtask));
    }

    // Delete ---------------------------------------
    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<String> delete(@PathVariable Long id) {
        subtaskService.deleteSubtask(id);
        return ResponseEntity.ok("Subtarefa deletada com sucesso");
    }
}
