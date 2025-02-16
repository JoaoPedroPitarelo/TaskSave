package joaopitarelo.tasksave.api.repository;

import joaopitarelo.tasksave.api.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Long> { } // <nomeEntidade, tipoChavePrimaria>
