package joaopitarelo.tasksave.api.domain.attachment;

import java.util.List;

public interface AttachmentRepository {
    List<Attachment> findByAtivoTrue();
    Attachment findByIdAndAtivoTrue(Long id);
}
