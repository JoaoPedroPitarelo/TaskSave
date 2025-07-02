package joaopitarelo.tasksave.api.interfaces.dtos.category;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record CreateCategory(
        @NotBlank
        String description,

        @NotBlank
        @Pattern(regexp = "^#?[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", message = "Cor deve estar no formato hexadecimal, ex: #AABBCC")
        String color
)
{ }
