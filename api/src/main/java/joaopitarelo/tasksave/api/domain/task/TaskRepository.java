package joaopitarelo.tasksave.api.domain.task;

import java.util.List;
import java.util.Optional;

public interface TaskRepository {
    List<Task> findByCompletedFalseAndUserIdOrderByPosition(Long id);
    List<Task> findByCompletedFalseAndUserIdAndCategoryId(Long id, Long categoryId);
    Task findByIdAndUserIdAndCompletedFalse(Long taskId, Long userId);
    Optional<Task> findByUserIdAndPositionAndCompletedFalse(Long id, Long newPosition);
}
