package joaopitarelo.tasksave.api.domain.task;

import java.util.List;

public interface TaskRepository {
    List<Task> findByCompletedFalseAndUserId(Long id);
    List<Task> findByCompletedFalseAndUserIdAndCategoryId(Long id, Long categoryId);
    Task findByIdAndUserIdAndCompletedFalse(Long taskId, Long userId);
}
