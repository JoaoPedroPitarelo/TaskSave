package joaopitarelo.tasksave.api.domain.attachment;


public interface AttachmentRepository {
    Attachment findByIdAndTaskIdAndAtivoTrue(Long id, Long taskId);
}
