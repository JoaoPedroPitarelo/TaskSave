package joaopitarelo.tasksave.api.infraestruture.exceptions;

import jakarta.persistence.EntityNotFoundException;
import org.apache.tomcat.websocket.AuthenticationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.nio.file.AccessDeniedException;
import java.util.List;

// Tratamento geral de exceções
@RestControllerAdvice
public class ApiExceptionHandler {

    // Trata erros do tipo Not Found, apesar de estar tratando os erros individualmente nos controllers
    // mas dessa forma caso fuja dos tratamentos individuas já existe um tratamento global para essa exceção
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<String> handleNotFoundException() {
        return ResponseEntity.notFound().build();
    }

    // Trata erros de validação
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<List<ErrorsDataValidation>> handleBadRequestException(MethodArgumentNotValidException e) {
        var errors = e.getFieldErrors();

        return ResponseEntity.badRequest().body(errors.stream().map(ErrorsDataValidation::new).toList());
    }

    // "DTO" para saída dos erros de validações
    public record ErrorsDataValidation(String campo, String message) {
        public ErrorsDataValidation(FieldError error) {
            // Usando o construtor padrão da classe
            this(error.getField(), error.getDefaultMessage());
        }
    }

    // Trata erros de BadCredentials
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<String> handleBadCredentials() {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid Credentials");
    }

    // Trata erros de Falha de autenticação
    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<String> handleAuthenticationError() {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Authentication Failed");
    }

    // Trata erros de acesso negado
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<String> handleDeniedAccess() {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access Denied");
    }

    // Trata erros internos do servidor
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> tratarErro500(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erro: " +ex.getLocalizedMessage());
    }
}
