package joaopitarelo.tasksave.api.application.services;

import jakarta.persistence.EntityNotFoundException;
import joaopitarelo.tasksave.api.domain.attachment.Attachment;
import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.domain.task.TaskRepository;
import joaopitarelo.tasksave.api.infraestruture.persistence.AttachmentJpaRepository;
import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Service
public class AttachmentService {

    @Autowired
    AttachmentJpaRepository attachmentRepository;

    @Autowired
    TaskRepository taskRepository;

    public Attachment getById(Long id, Long taskId) throws EntityNotFoundException {
        return attachmentRepository.findByIdAndTaskIdAndAtivoTrue(id, taskId);
    }

    public Attachment saveAttachment(Long userId, Long taskId, MultipartFile file) throws IOException {
        // Verificando se a tarefa existe
        Task task = taskRepository.findByIdAndUserIdAndCompletedFalse(taskId, userId);

        if (task == null) {
            throw new EntityNotFoundException("Task not found to attachment");
        }

        // Verificando o tipo do arquivo enviado (será tratado também no front-end)
        String fileExtension = FilenameUtils.getExtension(file.getOriginalFilename());

        List<String> validExtensions = List.of("png", "pdf", "jpg", "jpeg");

        if (!validExtensions.contains(fileExtension)) {
            throw new IllegalArgumentException("invalid archive type");
        }

        // Salvando o anexo na pasta do usuário
        String basePath = Paths.get("/app/storage", "user_uploads", "user_" + userId).toString();
        Path dir = Paths.get(basePath);

        Files.createDirectories(dir);

        String fileName = "task_" + taskId + "_" + System.currentTimeMillis() + "." + fileExtension;
        Path path = dir.resolve(fileName);

        file.transferTo(path.toFile()); // gravando fisicamente

        // Salvando a entidade e então salvando no banco de dados

        Path relativePath = Paths.get("/app/storage", "user_uploads", "user_" + userId, fileName);

        Attachment attachment = new Attachment();
        attachment.setTask(task);
        attachment.setFilePath(relativePath.toString());
        attachment.setFileName(file.getOriginalFilename());
        attachment.setFileType(fileExtension);
        attachment.setAtivo(true);
        attachmentRepository.save(attachment);

        return attachment;
    }

    public void delete(Attachment attachment) {
        attachment.setAtivo(false);
        attachmentRepository.save(attachment);
    }
}
