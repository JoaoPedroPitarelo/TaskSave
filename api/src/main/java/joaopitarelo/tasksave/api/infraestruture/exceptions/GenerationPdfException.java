package joaopitarelo.tasksave.api.infraestruture.exceptions;

public class GenerationPdfException extends RuntimeException {
    public GenerationPdfException(String message, Throwable cause) {
        super(message, cause);
    }
}
