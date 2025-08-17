package joaopitarelo.tasksave.api.interfaces.dtos.user;

public record OutputUser(Long id, String email, String verificationLink, boolean isVerified) {
}
