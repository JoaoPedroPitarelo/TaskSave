package joaopitarelo.tasksave.api.domain.category;

import java.util.List;
import java.util.Optional;

public interface CategoryRepository {
    List<Category> findByAtivoTrueAndUserIdOrderByPosition(Long userId);
    Optional<Category> findByIdAndUserIdAndAtivoTrue(Long categoryId, Long userId);
    Category findByUserIdAndIsDefaultTrue(Long userId);
    Optional<Category> findByUserIdAndPositionAndAtivoTrue(Long userId, Long position);
}
