package joaopitarelo.tasksave.api.domain.subtask;

import jakarta.persistence.*;
import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.subtask.CreateSubTask;
import joaopitarelo.tasksave.api.domain.task.Task;
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

    @Column(nullable = false)
    private boolean completed;

    @Enumerated(EnumType.STRING)
    private ReminderType reminderType;

    @ManyToOne
    @JoinColumn(name = "parent_task_id", nullable = false) // nome da coluna que irá armazenar a referencia da task
    private Task parentTask;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Construtor do DTO
    public Subtask(CreateSubTask subTask, Task task) {
        this.parentTask = task;
        this.title = subTask.title();
        this.description = subTask.description();
        this.deadline = subTask.deadline();
        this.lastModification = subTask.lastModification();
        this.priority = subTask.priority();
        this.completed = false;
        this.reminderType = task.getReminderType();
    }
}
