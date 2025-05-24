package joaopitarelo.tasksave.api.interfaces.dtos.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record ChangePassword(
        @NotBlank
        String token,
        @NotBlank
        @Pattern(
                regexp  = "^(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$",
                message = "The password must be at least 8 characters long and one special character "
        )
        String newPassword
) {
}
