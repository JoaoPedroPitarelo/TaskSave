package joaopitarelo.tasksave.api.application.services;

import joaopitarelo.tasksave.api.domain.category.Category;
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
    @Autowired
    private CategoryService categoryService; // para criação da categoria default

    @Override
    public UserDetails loadUserByUsername(String login) throws UsernameNotFoundException {
        User user = userRepository.findByLogin(login);

        if (user == null) {
            throw new UsernameNotFoundException("user not found");
        }

        return user;
    }

    public User loadUserByLogin(String login) throws UsernameNotFoundException {
        return userRepository.findByLogin(login);
    }

    public User loadUserById(Long id) {
        return userRepository.findById(id).orElse(null);
    }

    public void saveUser(User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setUserVerified(false);

        userRepository.save(user);

        // Criação da categoria padrão
        Category category = new Category();
        category.setUser(user);
        category.setDescription("Default");
        category.setDefault(true);
        category.setColor("#B0BEC5");

        categoryService.create(category);

        createUserFolder(user.getId());
    }

    public void changeUserPassword(User user, String newPassword) {
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    public void setUserVerified(User user) {
        user.setUserVerified(true);
        userRepository.save(user);
    }

    private void createUserFolder(Long userId) {
        // /app é a pasta de dentro do container que esta sendo linkada, por isso que fora do ambiente do container
        // a criação de pastas de usuários e uploads de arquivos não funciona
        String basePath = Paths.get("/app/storage", "user_uploads", "user_" + userId).toString();
        Path dir = Paths.get(basePath);

        try {
            if (!Files.exists(dir)) {
                Files.createDirectories(dir);
                System.out.println("User storage created at: " + dir.toString());
            }
        } catch (IOException exc) {
            System.err.println("Error when creating user folder " + exc);
        }
    }

    // TODO O QUE É ISSO? DOIS MÉTODOS IGUAIS???
    public User getUserByLogin(String email) {
        return userRepository.findByLogin(email) != null ? userRepository.findByLogin(email) : null;
    }
}
