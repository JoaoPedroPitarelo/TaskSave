package joaopitarelo.tasksave.api.domain.subtask;


public interface SubtaskRepository {
    Subtask findByIdAndUserIdAndCompletedFalse(Long id, Long userId);
}
