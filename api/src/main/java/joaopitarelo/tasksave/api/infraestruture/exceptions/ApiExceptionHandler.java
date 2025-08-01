package joaopitarelo.tasksave.api.infraestruture.exceptions;

import org.apache.tomcat.util.http.fileupload.InvalidFileNameException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.Map;

// Tratamento geral de exceções
@RestControllerAdvice
public class ApiExceptionHandler {


    // Trata erros de validação
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<List<ErrorsDataValidation>> handleBadRequestException(MethodArgumentNotValidException e) {
        var errors = e.getFieldErrors();

        return ResponseEntity.badRequest().body(errors.stream().map(ErrorsDataValidation::new).toList());
    }

    // "DTO" para saída dos erros de validações
    public record ErrorsDataValidation(String field, String message) {
        public ErrorsDataValidation(FieldError error) {
            // Usando o construtor padrão da classe
            this(error.getField(), error.getDefaultMessage());
        }
    }

    // Trata erros de BadCredentials
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<Map<String, Object>> handleBadCredentials(BadCredentialsException e) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error","invalid credentials"));
    }

    // Responde ao NoSuchAlgorithmException
    @ExceptionHandler(NoSuchAlgorithmException.class)
    public ResponseEntity<Map<String, Object>> handlerNoSuchAlgorithm(NoSuchAlgorithmException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
    }

    // Response ao SendingEmailException -≥ Exceção própria
    @ExceptionHandler(SendingEmailException.class)
    public ResponseEntity<Map<String, Object>> handlerSendingEmail(SendingEmailException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error sending e-mail", e.getMessage()));
    }

    // Trata erros internos do servidor
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> tratarErro500(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("Error", ex.getLocalizedMessage()));
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<Map<String, String>> handleMaxSizeUploadException(MaxUploadSizeExceededException e) {
        return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                .body(Map.of("error","upload archive is to large. Max file size is 10MB"));
    }

    @ExceptionHandler(InvalidFileNameException.class)
    public ResponseEntity<Map<String, String>> handleInvalidFileExtension(InvalidFileNameException e) {
        return ResponseEntity.status(HttpStatus.UNSUPPORTED_MEDIA_TYPE).body(Map.of("error", "invalid file type. Valid type: (.png .jpg .jpeg .pdf)"));
    }
}
