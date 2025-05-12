package joaopitarelo.tasksave.api.application.services;

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

@Service
public class AttachmentService {

    @Autowired
    AttachmentJpaRepository attachmentRepository;

    @Autowired
    TaskRepository taskRepository;

    public String saveAttachment(Long userId, Long taskId, MultipartFile file) throws IOException {
        // Verificando se a tarefa existe
        Task task = taskRepository.findByIdAndUserIdAndCompletedFalse(taskId, userId);

        if (task == null) throw new RuntimeException("Task not found to attachment");

        // Verificando o tipo do arquivo enviado (será tratado também no front-end)
        String extension = FilenameUtils.getExtension(file.getOriginalFilename());

        if (!extension.equals("png") && !extension.equals("jpg") && !extension.equals("pdf")) {
            throw new IllegalArgumentException("Invalid archive type");
        }

        // Salvando o anexo na pasta do usuário
        String basePath = Paths.get("").toAbsolutePath().toString();
        Path dir = Paths.get(basePath,"storage/user_uploads/user_" + userId);
        Files.createDirectories(dir);

        String fileName = "task_" + taskId + "_" + System.currentTimeMillis() + "." + extension;
        Path path = dir.resolve(fileName);

        file.transferTo(path.toFile()); // gravando fisicamente

        // Salvando a entidade e então salvando no banco de dados

        Path relativePath = Paths.get("storage", "user_uploads", "user_" + userId, fileName);

        Attachment attachment = new Attachment();
        attachment.setTask(task);
        attachment.setFilePath(relativePath.toString());
        attachment.setFileName(file.getOriginalFilename());
        attachment.setFileType(extension);
        attachmentRepository.save(attachment);

        return fileName;
    }
}
