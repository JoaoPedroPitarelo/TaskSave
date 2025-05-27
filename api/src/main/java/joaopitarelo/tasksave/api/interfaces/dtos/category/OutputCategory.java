package joaopitarelo.tasksave.api.interfaces.dtos.category;

import joaopitarelo.tasksave.api.domain.category.Category;

public record OutputCategory(
        Long id,
        String description,
        String color,
        boolean isDefault,
        boolean ativo
) {
    // Criando um construtor personalizado para esse record
    public OutputCategory(Category category) {
        this(category.getId(),
             category.getDescription(),
             category.getColor(),
             category.isDefault(),
             category.isAtivo()
        );
    }
}
