package joaopitarelo.tasksave.api.domain.subtask;


public interface SubtaskRepository {
    Subtask findByIdAndCompletedFalse(Long id);
}
