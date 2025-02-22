package joaopitarelo.tasksave.api.dto.category;

import jakarta.validation.constraints.NotNull;

public record UpdateCategory(
        String description,
        String color
) {
}
