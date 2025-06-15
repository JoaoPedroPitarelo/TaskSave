package joaopitarelo.tasksave.api.interfaces.dtos.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @Email(message = "Must be a email format")
        @NotBlank
        String login,
        @NotBlank
        String password
) { }
