package joaopitarelo.tasksave.api.infraestruture.security.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = OptionalNotBlankValidator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
public @interface OptionalNotBlank {
    String message() default "Campo não pode estar em branco";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
