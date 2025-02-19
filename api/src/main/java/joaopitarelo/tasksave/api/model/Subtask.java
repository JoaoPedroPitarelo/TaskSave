package joaopitarelo.tasksave.api.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import joaopitarelo.tasksave.api.dto.subtask.CreateSubTask;
import lombok.*;

import java.util.Date;

@Entity(name = "Subtask")
@Table(name = "subtask")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Subtask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String title;

    private String description;
    private Date deadline;

    @Column(nullable = false)
    private Date lastModification;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Priority priority;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status;

    @Enumerated(EnumType.STRING)
    private ReminderType reminderType;

    @ManyToOne
    @JoinColumn(name = "parent_task_id", nullable = false) // nome da coluna que irá armazenar a referencia da task
    private Task parentTask;

    // Construtor do DTO
    public Subtask(CreateSubTask subTask, Task task) {
        this.parentTask = task;
        this.title = subTask.title();
        this.description = subTask.description();
        this.deadline = subTask.deadline();
        this.lastModification = subTask.lastModification();
        this.priority = subTask.priority();
        this.status = subTask.status();
        this.reminderType = task.getReminderType();
    }

}
