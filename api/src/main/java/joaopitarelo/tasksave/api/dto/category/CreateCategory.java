package joaopitarelo.tasksave.api.dto.category;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record CreateCategory(
        @NotBlank // Não pode ser um String em branco " "
        String description,

        @NotBlank
        // @Pattern(regexp = "^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{4}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$\n") // TODO refazer isso aqui
        String color
)
{ }
