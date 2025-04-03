package joaopitarelo.tasksave.api.application.services;

import jakarta.transaction.Transactional;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.infraestruture.persistence.UserJpaRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest // Carrega o contexto da aplicação para testes reais
@ActiveProfiles("test") // Usa as configurações de properties-test.properties
@Transactional // Garante que os dados inseridos no bd serão apagados após os testes
/*
* Classe de teste responsável por testar a integração com o banco de dados.
* Nesse caso em específico o serviço de autenticação*/
class AuthenticationServiceTestIT { // Testando

    // Injetando as dependências
    @Autowired
    private AuthenticationService authenticationService;

    @Autowired
    private UserJpaRepository userJpaRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;


    @Test
    @DisplayName("Salva um usuário no banco de dados e verifica se realmente foi inserido, verifica se a senha foi criptografada")
    void createUser_ShouldSaveUserInDatabase() {
        // Criando novo usuário
        User user = new User();
        user.setLogin("fulano.silva@email.com");
        user.setPassword("MyPassword123%");

        // Chamando o méotodo de criação
        authenticationService.createUser(user);

        // Buscando o usuário salvo no banco
        var savedUser = userJpaRepository.findByLogin("fulano.silva@email.com");

        // Validando se o usuário salvo foi encontrado
        assertNotNull(savedUser);

        // Verificando se o usuário retornado foi realmente o que inserimos
        assertEquals("fulano.silva@email.com", savedUser.getUsername());

        // Vendo se a senha foi criptografada
        assertNotEquals("MyPassword123%", savedUser.getPassword());
        assertTrue(passwordEncoder.matches("MyPassword123%", savedUser.getPassword()));
    }
}