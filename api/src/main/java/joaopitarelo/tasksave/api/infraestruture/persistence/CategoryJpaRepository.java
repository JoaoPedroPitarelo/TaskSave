package joaopitarelo.tasksave.api.infraestruture.persistence;

import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.domain.category.CategoryRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CategoryJpaRepository extends JpaRepository<Category, Long>, CategoryRepository {
    @Query("SELECT MAX(c.position) FROM Category c WHERE c.ativo = true AND c.user.id = :userId")
    Optional<Long> findMaxPositionByUserAndAtivoTrue(@Param("userId") Long userId);
}
