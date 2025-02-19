package joaopitarelo.tasksave.api.repository;

import joaopitarelo.tasksave.api.model.Status;
import joaopitarelo.tasksave.api.model.Task;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findAllByStatus(Status status);
    Task findByIdAndStatus(Long id, Status status);
}
