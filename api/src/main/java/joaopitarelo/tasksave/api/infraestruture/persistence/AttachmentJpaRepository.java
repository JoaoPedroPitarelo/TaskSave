package joaopitarelo.tasksave.api.infraestruture.persistence;

import joaopitarelo.tasksave.api.domain.attachment.Attachment;
import joaopitarelo.tasksave.api.domain.attachment.AttachmentRepository;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttachmentJpaRepository extends JpaRepository<Attachment, Long>, AttachmentRepository {
}
