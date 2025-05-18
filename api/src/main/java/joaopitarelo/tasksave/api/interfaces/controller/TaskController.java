package joaopitarelo.tasksave.api.interfaces.controller;

import joaopitarelo.tasksave.api.domain.attachment.Attachment;
import joaopitarelo.tasksave.api.interfaces.dtos.attachment.OutputAttachment;
import org.apache.coyote.Response;
import org.springframework.core.io.Resource;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.application.services.AttachmentService;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.task.OutputTask;
import joaopitarelo.tasksave.api.interfaces.dtos.task.UpdateTask;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.application.services.CategoryService;
import joaopitarelo.tasksave.api.application.services.TaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import joaopitarelo.tasksave.api.interfaces.dtos.task.CreateTask;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@RestController
@RequestMapping("task")
public class TaskController {

    @Autowired
    private TaskService taskService;
    @Autowired
    private CategoryService categoryService;
    @Autowired
    private AttachmentService attachmentService;


    // GetAll ------------------------------------
    @GetMapping
    public ResponseEntity<List<OutputTask>> getAll(@AuthenticationPrincipal User user) {
        // TODO Tratar a exceção = "e se não tiver nenhuma tarefa?"
        return ResponseEntity.ok(taskService.getTasks(user.getId()).stream().map(OutputTask::new).toList());
    }

    // GetById -------------------------------------
    @GetMapping("/{taskId}")
    public ResponseEntity<?> getById(@PathVariable Long taskId, @AuthenticationPrincipal User user) {
        Task task = taskService.getTaskById(taskId, user.getId());

        if (task == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Task not found");

        return ResponseEntity.ok(new OutputTask(task));
    }

    // Create ------------------------------------
    @PostMapping("/create")
    @Transactional
    public ResponseEntity<?> create(@RequestBody @Valid CreateTask newTask,
                                    UriComponentsBuilder uriBuilder,
                                    @AuthenticationPrincipal User user) {
        Category category = categoryService.getCategoryById(newTask.categoryId(), user.getId());

        if (category == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Category not found");

        Task task = new Task(newTask, category);
        taskService.createTask(task, user);

        var uri = uriBuilder.path("/task/{id}").buildAndExpand(task.getId()).toUri();

        return ResponseEntity.created(uri).body(new OutputTask(task));
    }

    // Update -------------------------------------
    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<?> update(@RequestBody @Valid UpdateTask modifiedTask,
                                    @PathVariable Long id,
                                    @AuthenticationPrincipal User user) {
        Task task = taskService.getTaskById(id, user.getId());
        if (task == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Task not found");


        // TODO Arrumar essa parada aqui, pois da forma que está, toda vez que for fazer o update tem que mandar o id da categoria e não é isso que eu quero. Quero que mande somente o que for mudar
        Category category = categoryService.getCategoryById(modifiedTask.categoryId(), user.getId());
        if (category == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Category not found");

        taskService.updateTask(task, modifiedTask, category);
        return ResponseEntity.ok(new OutputTask(task));
    }

    // Upload de anexos
    @PostMapping("/attachment/upload") // subir o arquivo
    public ResponseEntity<?> uploadAttachment(
            @RequestParam("file") MultipartFile file,
            @RequestParam("taskId") Long taskId,
            UriComponentsBuilder uriBuilder,
            @AuthenticationPrincipal User user
    ) {
        try {
            Attachment attachment = attachmentService.saveAttachment(user.getId(), taskId, file);

            var uri = uriBuilder.path("/task/attachment/download/{id}").buildAndExpand(attachment.getId()).toUri();

            return ResponseEntity.created(uri).body(new OutputAttachment(attachment));
        } catch (IOException exc) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erro ao salvar o arquivo: " + exc.getMessage());
        }
    }

    // Download de anexo
    @GetMapping("/attachment/{attachmentId}")
    public ResponseEntity<Resource> downloadAttachment(
        @PathVariable Long attachmentId,
        @AuthenticationPrincipal User user
    ) {
        Attachment attachment;

        try {
            attachment = attachmentService.getById(attachmentId);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        // Montando o caminho para buscar o arquivo
        Path filePath = Paths.get(attachment.getFilePath());

        // Verificando se o arquivo existe
        if (!Files.exists(filePath)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        // Buscando o arquivo
        try {
            Resource resource = new UrlResource((filePath.toUri()));

            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename\"" + attachment.getFileName() + "\"")
                    .body(resource);
        } catch (MalformedURLException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/attachment/{attachmentId}")
    public ResponseEntity<?> deleteAttachment(@PathVariable Long attachmentId) {
        Attachment attachment;

        try {
            attachment = attachmentService.getById(attachmentId);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        // Montando o caminho para buscar o arquivo
        Path filePath = Paths.get(attachment.getFilePath());

        // Verificando se o arquivo existe
        if (!Files.exists(filePath)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        // Deletando no disco rígido
        try {
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }

        // Deletando do banco de dados
        attachmentService.delete(attachment);

       return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }

    // Delete -------------------------------------
    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<String> delete(@PathVariable Long id) {
        taskService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }
}
