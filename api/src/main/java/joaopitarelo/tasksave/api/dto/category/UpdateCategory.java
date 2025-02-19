package joaopitarelo.tasksave.api.dto.category;

import jakarta.validation.constraints.NotNull;

public record UpdateCategory(
        @NotNull
        Long id,
        String description,
        String color
) {
}
