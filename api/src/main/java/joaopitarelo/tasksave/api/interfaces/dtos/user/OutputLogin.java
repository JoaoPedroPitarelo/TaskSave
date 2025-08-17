package joaopitarelo.tasksave.api.interfaces.dtos.user;

import joaopitarelo.tasksave.api.domain.user.User;

public record OutputLogin(
    UserDto user,
    String accessToken,
    String refreshToken
) {
    OutputLogin(User user, String accessToken, String refreshToken) {
        this(
            new UserDto(user.getId(), user.getLogin()),
            accessToken,
            refreshToken
        );
    }
}
