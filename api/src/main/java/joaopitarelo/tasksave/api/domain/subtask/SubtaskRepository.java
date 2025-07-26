package joaopitarelo.tasksave.api.domain.subtask;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SubtaskRepository {
    Subtask findByIdAndUserIdAndCompletedFalse(Long id, Long userId);
    @Query("SELECT MAX(s.position) " +
           "FROM Subtask s WHERE s.completed = false AND s.user.id = :userId AND s.parentTask.id = :parentTaskId")
    Optional<Long> findMaxPositionByUserIdAndParentTaskIdAndCompletedFalse(
            @Param("userId") Long userId,
            @Param("parentTaskId") Long parentTaskId
    );
    List<Subtask> findByUserIdAndParentTaskIdAndCompletedFalse(Long userId, Long parentTaskId);
    Optional<Subtask> findByUserIdAndParentTaskIdAndPositionAndCompletedFalse(Long userId, Long parentTaskId, Long position);
    Optional<List<Subtask>> findByParentTaskIdAndUserIdAndCompletedFalse(Long parentTaskId, Long userId);
}
