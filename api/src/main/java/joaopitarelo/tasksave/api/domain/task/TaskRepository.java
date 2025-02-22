package joaopitarelo.tasksave.api.domain.task;

import java.util.List;

public interface TaskRepository {
    List<Task> findByCompletedFalse();
    Task findByIdAndCompletedFalse(Long id);
}
