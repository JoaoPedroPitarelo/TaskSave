package joaopitarelo.tasksave.api.domain.category;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.category.CreateCategory;
import joaopitarelo.tasksave.api.domain.task.Task;
import lombok.*;

import java.util.List;

@Entity(name = "Category")
@Table(name = "category")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "description", unique = true, nullable = false, length = 50)
    private String description;

    @Column(name = "color", unique = false, nullable = false, length = 7)
    private String color;

    @Column(name = "ativo", nullable = false)
    private boolean ativo;

    @Column(name = "is_default", nullable = false)
    private boolean isDefault = false;

    @Column(name = "position", nullable = false)
    private Long position;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @OneToMany(mappedBy = "category")
    @JsonIgnore
    private List<Task> tasks;

    // Construtor com o DTO(record)
    public Category(CreateCategory category) {
        this.description = category.description();
        this.color = category.color();
    }

}
