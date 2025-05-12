package joaopitarelo.tasksave.api.domain.task;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import joaopitarelo.tasksave.api.domain.attachment.Attachment;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.domain.enums.Priority;
import joaopitarelo.tasksave.api.domain.enums.ReminderType;
import joaopitarelo.tasksave.api.domain.subtask.Subtask;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.task.CreateTask;
import lombok.*;

import java.util.Date;
import java.util.List;

@Entity(name = "Task")
@Table(name = "task")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Task {

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
    @Column(nullable = false, columnDefinition = "priority")
    private Priority priority;

    @ManyToOne
    @JoinColumn(name = "category_id", nullable = false) // nome da coluna que irá armazenar a referência da categoria
    private Category category;

    @Column(nullable = false, columnDefinition = "completed")
    private boolean completed;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "reminder_type")
    private ReminderType reminderType;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @OneToMany(mappedBy = "parentTask", cascade = CascadeType.ALL, orphanRemoval = true)
    // mappedBy = nome do atributo que fará essa relação ou seja no caso de Subtasks quem fará isso será o atributo task
    @JsonIgnore
    private List<Subtask> subtasks;

    @OneToMany(mappedBy = "task", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<Attachment> attachments;

    // Construtor para DTO de criação
    public Task(CreateTask task, Category category) {
        this.title = task.title();
        this.description = task.description();
        this.deadline = task.deadline();
        this.lastModification = task.lastModification();
        this.priority = task.priority();
        this.category = category;
        this.reminderType = task.reminderType();
    }
}
