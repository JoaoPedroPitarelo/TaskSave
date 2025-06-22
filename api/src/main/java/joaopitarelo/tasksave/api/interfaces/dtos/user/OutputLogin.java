package joaopitarelo.tasksave.api.interfaces.dtos.user;

public record OutputLogin(Long userId, String accessToken, String refreshToken) {
}
