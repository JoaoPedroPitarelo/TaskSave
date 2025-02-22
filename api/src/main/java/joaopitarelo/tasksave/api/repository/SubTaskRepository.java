package joaopitarelo.tasksave.api.repository;

import joaopitarelo.tasksave.api.model.Subtask;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SubTaskRepository extends JpaRepository<Subtask, Long> {
    Subtask findByIdAndCompletedFalse(Long id);
}
