package joaopitarelo.tasksave.api.infraestruture.exceptions;

public class SendingEmailException extends RuntimeException {
    public SendingEmailException(String message, Throwable causa) {
        super(message, causa);
    }
}
