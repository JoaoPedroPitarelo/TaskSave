package joaopitarelo.tasksave.api.interfaces.dtos.attachment;

import joaopitarelo.tasksave.api.domain.attachment.Attachment;

import java.time.LocalDateTime;

public record OutputAttachment(
        Long id,
        Long taskId,
        String filePath,
        String fileName,
        String fileType,
        String downloadEndPoint,
        LocalDateTime uploadedAt,
        boolean ativo
) {
    public OutputAttachment(Attachment attachment) {
        this(
            attachment.getId(),
            attachment.getTask().getId(),
            attachment.getFilePath(),
            attachment.getFileName(),
            attachment.getFileType(),
            "/task/" + attachment.getTask().getId() + "/attachment/" + attachment.getId(),
            attachment.getUploadedAt(),
            attachment.isAtivo()
        );
    }
}
