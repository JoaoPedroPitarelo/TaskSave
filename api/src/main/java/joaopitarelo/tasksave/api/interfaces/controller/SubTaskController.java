package joaopitarelo.tasksave.api.interfaces.controller;


import jakarta.transaction.Transactional;
import jakarta.validation.Valid;

import joaopitarelo.tasksave.api.application.services.SubtaskService;
import joaopitarelo.tasksave.api.application.services.TaskService;
import joaopitarelo.tasksave.api.domain.exceptions.InvalidPositionException;
import joaopitarelo.tasksave.api.domain.subtask.Subtask;
import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.subtask.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Map;

@RestController
@RequestMapping("subtask")
public class SubTaskController {

    @Autowired
    private SubtaskService subtaskService;
    @Autowired
    private TaskService taskService;


    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Subtask subtask = subtaskService.getById(id, user.getId());

        if (subtask == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        return ResponseEntity.ok(Map.of("subtask", new OutputSubtask(subtask)));
    }


    @PostMapping("/create")
    public ResponseEntity<?> create(@RequestBody @Valid CreateSubTask newSubtask,
                                    UriComponentsBuilder uriBuilder,
                                    @AuthenticationPrincipal User user) {
        Task task = taskService.getById(newSubtask.parentTaskId(), user.getId());

        if (task == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "parent task not found"));
        }

        Subtask subtask = new Subtask(newSubtask, task);
        subtaskService.create(subtask, user);

        var uri = uriBuilder.path("/subtask/{id}").buildAndExpand(subtask.getId()).toUri();

        return ResponseEntity.created(uri).body(Map.of("subtask", new OutputSubtask(subtask)));
    }

    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<?> update(@RequestBody @Valid UpdateSubtask modifiedSubtask,
                                    @PathVariable Long id,
                                    @AuthenticationPrincipal User user) {

        Subtask subtask = subtaskService.getById(id, user.getId());
        if (subtask == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message","subtask not found"));
        }

        try {
            subtaskService.update(modifiedSubtask, subtask);
        } catch (InvalidPositionException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
        }
        return ResponseEntity.ok(Map.of("subtask", new OutputSubtask(subtask)));
    }

    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<String> delete(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Subtask subtask = subtaskService.getById(id, user.getId());

        if (subtask == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        subtaskService.delete(id, user.getId());
        return ResponseEntity.noContent().build();
    }
}
