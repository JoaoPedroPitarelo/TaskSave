package joaopitarelo.tasksave.api.application.services;

import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.infraestruture.persistence.UserJpaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
public class AuthenticationService implements UserDetailsService { // interface do Spring Security

    @Autowired
    private UserJpaRepository userRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public UserDetails loadUserByUsername(String login) throws UsernameNotFoundException {
        User user = userRepository.findByLogin(login);

        if (user == null) {
            throw new UsernameNotFoundException("Usuário não encontrado");
        }

        return user;
    }

    public User loadUserByLogin(String login) throws UsernameNotFoundException {
        return userRepository.findByLogin(login);
    }

    public User getUserById(Long id) {
        return userRepository.findById(id).orElse(null);
    }

    public void createUser(User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setUserVerified(false);

        userRepository.save(user);

        createUploadDir(user.getId());
    }

    public void setUserVerified(User user) {
        user.setUserVerified(true);
        userRepository.save(user);
    }

    private void createUploadDir(Long userId) {
        Path dir = Paths.get("storage/user_uploads", "user_" + userId);

        try {
            if (!Files.exists(dir)) {
                Files.createDirectories(dir);
                System.out.println("User storage created at: " + dir.toString());
            }
        } catch (IOException exc) {
            System.err.println("Error when creating user folder " + exc.getMessage());
        }
    }
}
