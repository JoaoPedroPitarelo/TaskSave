package joaopitarelo.tasksave.api.controller;


import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.subtask.CreateSubTask;
import joaopitarelo.tasksave.api.dto.subtask.OutputSubtask;
import joaopitarelo.tasksave.api.dto.subtask.UpdateSubtask;
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

@RestController
@RequestMapping("subtask")
public class SubTaskController {

    @Autowired
    private SubtaskService subtaskService;
    @Autowired
    private TaskService taskService;

    // Create ----------------------------------------
    @PostMapping("/create")
    public ResponseEntity<String> create(@RequestBody @Valid CreateSubTask subTaskDTO) {
        Task task = taskService.getTaskById(subTaskDTO.parentTaskId());
        if (task == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Tarefa pai não encontrada");

        subtaskService.createSubtask(subTaskDTO, task);
        return ResponseEntity.status(HttpStatus.CREATED).body("Subtask adiciona à tarefa" + String.valueOf(task.getId()));
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
