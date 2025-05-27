package joaopitarelo.tasksave.api.domain.category;

import java.util.List;

public interface CategoryRepository {
    List<Category> findByAtivoTrueAndUserId(Long userId);
    Category findByIdAndUserIdAndAtivoTrue(Long categoryId, Long userId);
    Category findByUserIdAndIsDefaultTrue(Long userId);
}
