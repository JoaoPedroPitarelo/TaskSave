package joaopitarelo.tasksave.api.interfaces.dtos.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record RescueLogin(
        @NotBlank
        @Email(message = "Must be a email format")
        String email
) { }
