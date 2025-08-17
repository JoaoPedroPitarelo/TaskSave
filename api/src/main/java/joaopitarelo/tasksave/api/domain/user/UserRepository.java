package joaopitarelo.tasksave.api.domain.user;


public interface UserRepository {
    User findByLogin(String login);
}
