package joaopitarelo.tasksave.api.interfaces.dtos.category;

import jakarta.validation.constraints.Pattern;
import joaopitarelo.tasksave.api.infraestruture.security.validation.OptionalNotBlank;

public record UpdateCategory(
        @OptionalNotBlank
        String description,
        @OptionalNotBlank
        @Pattern(regexp = "^#?[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", message = "Cor deve estar no formato hexadecimal, ex: #AABBCC")
        String color,
        Long position
) {
}
