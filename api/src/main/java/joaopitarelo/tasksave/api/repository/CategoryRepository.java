package joaopitarelo.tasksave.api.repository;

import joaopitarelo.tasksave.api.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    List<Category> findByAtivoTrue();
    Category findByIdAndAtivoTrue(Long id);
} // <nomeEntidade, tipoChavePrimaria>
