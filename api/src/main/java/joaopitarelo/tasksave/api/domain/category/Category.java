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
@EqualsAndHashCode(of = "id") // Faz o equals e o hashcode em cima do id e não de todos os atributos
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

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = true) // TODO mudar para false depois quanto tiver usuário
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
