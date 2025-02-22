package joaopitarelo.tasksave.api.infraestruture.persistence;

import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.domain.task.TaskRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskJpaRepository extends JpaRepository<Task, Long>, TaskRepository {
}
