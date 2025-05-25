package joaopitarelo.tasksave.api.infraestruture.persistence;

import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.domain.category.CategoryRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryJpaRepository extends JpaRepository<Category, Long>, CategoryRepository { // <nomeEntidade, tipoChavePrimaria>
}
