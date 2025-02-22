package joaopitarelo.tasksave.api.infraestruture.persistence;

import joaopitarelo.tasksave.api.domain.subtask.Subtask;
import joaopitarelo.tasksave.api.domain.subtask.SubtaskRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SubTaskJpaRepository extends JpaRepository<Subtask, Long>, SubtaskRepository {
}
