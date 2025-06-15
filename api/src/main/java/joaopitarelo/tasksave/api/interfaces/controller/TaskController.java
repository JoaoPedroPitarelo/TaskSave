package joaopitarelo.tasksave.api.interfaces.controller;

import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;

import joaopitarelo.tasksave.api.application.services.AttachmentService;
import joaopitarelo.tasksave.api.application.services.CategoryService;
import joaopitarelo.tasksave.api.application.services.TaskService;
import joaopitarelo.tasksave.api.application.services.PDFService;
import joaopitarelo.tasksave.api.domain.attachment.Attachment;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.attachment.OutputAttachment;
import joaopitarelo.tasksave.api.interfaces.dtos.task.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;


@RestController
@RequestMapping("task")
public class TaskController {

    @Autowired
    private TaskService taskService;
    @Autowired
    private CategoryService categoryService;
    @Autowired
    private AttachmentService attachmentService;
    @Autowired
    private PDFService pdfService;

    @GetMapping
    public ResponseEntity<Map<String, List<OutputTask>>> getAll(@AuthenticationPrincipal User user) {
        Map<String, List<OutputTask>> listTasks = Map.of("tasks", taskService.getTasks(user.getId()).stream().map(OutputTask::new).toList());
        return ResponseEntity.ok(listTasks);
    }

    @GetMapping("/{taskId}")
    public ResponseEntity<?> getById(@PathVariable Long taskId, @AuthenticationPrincipal User user) {
        Task task = taskService.getTaskById(taskId, user.getId());

        if (task == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).build();

        return ResponseEntity.ok(Map.of("task", new OutputTask(task)));
    }

    @PostMapping("/create")
    @Transactional
    public ResponseEntity<?> create(@RequestBody @Valid CreateTask newTask,
                                    UriComponentsBuilder uriBuilder,
                                    @AuthenticationPrincipal User user) {
        Category category = categoryService.getDefaultCategory(user.getId());
        if (newTask.categoryId() != null) {
            category = categoryService.getById(newTask.categoryId(), user.getId());

            if (category == null)  {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "category not found"));
            }
        }

        Task task = new Task(newTask, category);
        taskService.createTask(task, user);

        var uri = uriBuilder.path("/task/{id}").buildAndExpand(task.getId()).toUri();

        return ResponseEntity.created(uri).body(Map.of("task", new OutputTask(task)));
    }

    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<?> update(@RequestBody @Valid UpdateTask modifiedTask,
                                    @PathVariable Long id,
                                    @AuthenticationPrincipal User user) {
        Task task = taskService.getTaskById(id, user.getId());

        if (task == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Task not found");
        }

        if (modifiedTask.categoryId() != null) {
            Category category = categoryService.getById(modifiedTask.categoryId(), user.getId());
            if (category == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Category not found");
            }
            taskService.updateTask(task, modifiedTask, category);
        } else {
            taskService.updateTask(task, modifiedTask, null);
        }

        return ResponseEntity.ok(Map.of("task", new OutputTask(task)));
    }

    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<String> delete(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Task task = taskService.getTaskById(id, user.getId());

        if (task == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        taskService.deleteTask(task);

        return ResponseEntity.noContent().build();
    }

    @PostMapping("/attachment/upload") // subir o arquivo
    public ResponseEntity<?> uploadAttachment(
            @RequestParam("file") MultipartFile file,
            @RequestParam("taskId") Long taskId,
            UriComponentsBuilder uriBuilder,
            @AuthenticationPrincipal User user
    ) {
        Attachment attachment;

        try {
            attachment = attachmentService.saveAttachment(user.getId(), taskId, file);
        } catch (IOException exc) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro","during saving archive " + exc.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", e.getMessage()));
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "task not found"));
        }

        var uri = uriBuilder.path("/task/attachment/download/{id}").buildAndExpand(attachment.getId()).toUri();

        return ResponseEntity.created(uri)
                .body(Map.of("attachment", new OutputAttachment(attachment)));
    }

    @GetMapping("{taskId}/attachment/{attachmentId}")
    public ResponseEntity<?> downloadAttachment(
        @PathVariable Long attachmentId,
        @PathVariable Long taskId,
        @AuthenticationPrincipal User user
    ) {
        Task task = taskService.getTaskById(taskId, user.getId());
        if (task == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "task not found"));
        }

        Attachment attachment = attachmentService.getById(attachmentId, task.getId());
        if (attachment == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "attachment not found"));
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

    @DeleteMapping("{taskId}/attachment/{attachmentId}")
    public ResponseEntity<?> deleteAttachment(
            @PathVariable Long attachmentId,
            @PathVariable Long taskId,
            @AuthenticationPrincipal User user) {

        Task task = taskService.getTaskById(taskId, user.getId());
        if (task == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "task not found"));
        }

        Attachment attachment = attachmentService.getById(attachmentId, task.getId());
        if (attachment == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "attachment not found"));
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

    @GetMapping("/export/pdf")
    public ResponseEntity<?> exportToPdf(
            @RequestParam(required = false) Long idCategory,
            @AuthenticationPrincipal User user) {
        List<Task> tasks;
        Category category = null;
        if (idCategory != null) {
            category = categoryService.getById(idCategory, user.getId());

            if (category == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("message", "category not found"));
            }
            tasks = taskService.getTaskByCategory(user.getId(), idCategory);
        } else {
            tasks = taskService.getTasks(user.getId());
        }

        byte[] pdf;

        try {
            pdf = pdfService.generatePDF(user.getLogin(), category, tasks);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "generating tasks to PDF " + e.getMessage()));
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=tasks.pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

}
