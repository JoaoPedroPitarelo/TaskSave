package joaopitarelo.tasksave.api.interfaces.dtos.user;

import jakarta.validation.constraints.NotBlank;

public record RefreshToken(
        @NotBlank
        String refreshToken
) {
}
