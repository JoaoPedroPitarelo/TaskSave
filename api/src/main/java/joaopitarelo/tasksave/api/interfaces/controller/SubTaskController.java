package joaopitarelo.tasksave.api.interfaces.controller;


import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.subtask.CreateSubTask;
import joaopitarelo.tasksave.api.interfaces.dtos.subtask.OutputSubtask;
import joaopitarelo.tasksave.api.interfaces.dtos.subtask.UpdateSubtask;
import joaopitarelo.tasksave.api.domain.subtask.Subtask;
import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.application.services.SubtaskService;
import joaopitarelo.tasksave.api.application.services.TaskService;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
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
    public ResponseEntity<?> getById(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Subtask subtask = subtaskService.getById(id, user.getId());

        if (subtask == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Subtask  not found");

        return ResponseEntity.ok(new OutputSubtask(subtask));
    }


    // Create ----------------------------------------
    @PostMapping("/create")
    public ResponseEntity<?> create(@RequestBody @Valid CreateSubTask newSubtask,
                                    UriComponentsBuilder uriBuilder,
                                    @AuthenticationPrincipal User user) {
        Task task = taskService.getTaskById(newSubtask.parentTaskId(), user.getId());
        if (task == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Parent Task not found");

        Subtask subtask = new Subtask(newSubtask, task);
        subtask.setUser(user);
        subtaskService.createSubtask(subtask);

        var uri = uriBuilder.path("/subtask/{id}").buildAndExpand(subtask.getId()).toUri();

        return ResponseEntity.created(uri).body(new OutputSubtask(subtask));
    }

    // Update ----------------------------------------
    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<?> update(@RequestBody @Valid UpdateSubtask modifiedSubtask,
                                    @PathVariable Long id,
                                    @AuthenticationPrincipal User user) {
        Subtask subtask = subtaskService.getById(id, user.getId());
        if (subtask == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Subtask not found");

        subtaskService.updateSubtask(modifiedSubtask, subtask);
        return ResponseEntity.ok(new OutputSubtask(subtask));
    }

    // Delete ---------------------------------------
    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<String> delete(@PathVariable Long id,
                                         @AuthenticationPrincipal User user) {
        subtaskService.deleteSubtask(id, user.getId());
        return ResponseEntity.noContent().build();
    }
}
