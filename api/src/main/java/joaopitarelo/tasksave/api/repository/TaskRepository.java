package joaopitarelo.tasksave.api.repository;

import joaopitarelo.tasksave.api.model.Task;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskRepository extends JpaRepository<Task, Long> { // To_do TaskRepository também é um JpaRepository
}
