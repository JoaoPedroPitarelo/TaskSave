package joaopitarelo.tasksave.api.model;


import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import joaopitarelo.tasksave.api.dto.category.CreateCategory;
import lombok.*;

import java.util.List;

@Entity(name = "Category")
@Table(name = "category")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id") // Faz o equals e o hashcode encima do id e não de todos os atributos
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "description", unique = true, nullable = false, length = 50)
    private String description;

    @Column(name = "color", unique = false, nullable = false, length = 7)
    private String color;

    @OneToMany(mappedBy = "category")
    @JsonIgnore
    private List<Task> tasks;

    // Construtor com o DTO(record)
    public Category(CreateCategory category) {
        this.description = category.description();
        this.color = category.color();
    }
}
