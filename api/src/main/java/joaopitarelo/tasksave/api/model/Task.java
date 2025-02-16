package joaopitarelo.tasksave.api.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import joaopitarelo.tasksave.api.dto.task.CreateTask;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.sql.Date;
import java.util.List;

@Entity(name = "Task")
@Table(name = "task")
@Getter
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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "status")
    private Status status;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "reminder_type")
    private ReminderType reminderType;

    @OneToMany(mappedBy = "parentTask", cascade = CascadeType.ALL, orphanRemoval = true)
    // mappedBy = nome do atributo que fará essa relação ou seja no caso de Subtasks quem fará isso será o atributo task
    @JsonIgnore
    private List<Subtask> subtasks;

    // Construtor do DTO
    public Task(CreateTask task, Category category) {
        this.title = task.title();
        this.description = task.description();
        this.deadline = task.deadline();
        this.lastModification = task.lastModification();
        this.priority = task.priority();
        this.category = category;
        this.status = task.status();
        this.reminderType = task.reminderType();
    }
}
