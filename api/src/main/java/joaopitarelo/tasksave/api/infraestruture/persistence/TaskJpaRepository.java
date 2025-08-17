package joaopitarelo.tasksave.api.infraestruture.persistence;

import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.domain.task.TaskRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TaskJpaRepository extends JpaRepository<Task, Long>, TaskRepository {
    @Query("SELECT MAX(t.position) FROM Task t WHERE t.completed = false AND t.user.id = :userId")
    Optional<Long> findMaxPositionByUserAndCompletedFalse(@Param("userId") Long userId);
}
