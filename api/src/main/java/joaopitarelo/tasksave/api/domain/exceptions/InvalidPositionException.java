package joaopitarelo.tasksave.api.domain.exceptions;

public class InvalidPositionException extends RuntimeException {
    public InvalidPositionException(String message) {
        super(message);
    }
}
