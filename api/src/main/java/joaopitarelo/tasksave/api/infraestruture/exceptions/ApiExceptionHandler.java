package joaopitarelo.tasksave.api.infraestruture.exceptions;

import jakarta.persistence.EntityNotFoundException;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

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
}
