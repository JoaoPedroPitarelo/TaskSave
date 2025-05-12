package joaopitarelo.tasksave.api.domain.attachment;

import jakarta.persistence.*;
import joaopitarelo.tasksave.api.domain.task.Task;
import lombok.*;

import java.time.LocalDateTime;

@Entity(name = "Attachment")
@Table(name = "attachment")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Attachment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne()
    @JoinColumn(name = "task", nullable = false)
    private Task task;

    private String filePath;

    private String fileName;

    private String fileType;

    private LocalDateTime uploadedAt = LocalDateTime.now();
}
