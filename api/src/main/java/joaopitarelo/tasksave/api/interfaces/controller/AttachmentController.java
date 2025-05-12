package joaopitarelo.tasksave.api.interfaces.controller;

import joaopitarelo.tasksave.api.application.services.AttachmentService;
import joaopitarelo.tasksave.api.domain.user.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("attachment")
public class AttachmentController {

    @Autowired
    private AttachmentService attachmentService;

    @PostMapping("/upload") // subir o arquivo
    public ResponseEntity<?> uploadAttachment(
            @RequestParam("file") MultipartFile file,
            @RequestParam("taskId") Long taskId,
            @AuthenticationPrincipal User user
    ) {
        try {
            attachmentService.saveAttachment(user.getId(), taskId, file);
            return ResponseEntity.ok("Arquivo salvo com sucesso");
        } catch (IOException exc) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erro ao salvar o arquivo: " + exc.getMessage());
        }
    }
}
