package joaopitarelo.tasksave.api.controller;


import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.subtask.CreateSubTask;
import joaopitarelo.tasksave.api.model.Subtask;
import joaopitarelo.tasksave.api.model.Task;
import joaopitarelo.tasksave.api.repository.SubTaskRepository;
import joaopitarelo.tasksave.api.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("subtask")
public class SubTaskController {

    // TODO getById []
    // TODO delete  []
    // TODO UPDATE  []
    //

    @Autowired
    private SubTaskRepository subTaskRepository;
    @Autowired
    private TaskRepository taskRepository;


    @PostMapping("/create")
    public ResponseEntity<String> create(@RequestBody @Valid CreateSubTask subTask) {
        Task task = taskRepository.findById(subTask.parentTaskId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Tarefa pai não existe ou não foi encontrada"));
        Subtask newSubTask = new Subtask(subTask, task);
        subTaskRepository.save(newSubTask);

        return ResponseEntity.status(HttpStatus.CREATED).body("Subtask adiciona à tarefa" + String.valueOf(task.getId()));
    }
}
