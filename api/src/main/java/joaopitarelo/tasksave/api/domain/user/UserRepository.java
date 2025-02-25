package joaopitarelo.tasksave.api.domain.user;

import org.springframework.security.core.userdetails.UserDetails;

public interface UserRepository {
    UserDetails findByLogin(String login);
}
