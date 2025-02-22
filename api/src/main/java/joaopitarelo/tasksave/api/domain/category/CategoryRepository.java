package joaopitarelo.tasksave.api.domain.category;

import java.util.List;

public interface CategoryRepository {
    List<Category> findByAtivoTrue();
    Category findByIdAndAtivoTrue(Long id);
}
