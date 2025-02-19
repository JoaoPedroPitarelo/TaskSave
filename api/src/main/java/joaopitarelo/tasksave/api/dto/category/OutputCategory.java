package joaopitarelo.tasksave.api.dto.category;

import joaopitarelo.tasksave.api.model.Category;

public record OutputCategory(
        Long id,
        String description,
        String color,
        boolean ativo
) {
    // Criando um construtor personalizado para esse record
    public OutputCategory(Category category) {
        this(category.getId(),
             category.getDescription(),
             category.getColor(),
             category.isAtivo()
        );
    }
}
