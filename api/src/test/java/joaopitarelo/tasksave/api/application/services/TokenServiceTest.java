package joaopitarelo.tasksave.api.application.services;


import jakarta.transaction.Transactional;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.user.TokenData;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest // Carrega o contexto da nossa aplicação, meio que configurando o ambiente de testes
@ActiveProfiles("test") // Usa as configurações escritas em properties-application-test.properties
@Transactional // Faz com que todos os dados inseridos no banco de dados sejam apagados após os testes, deixando os testes mais limpos
class TokenServiceTest {

    // Injetando as dependências para os testes
    @Autowired
    private TokenService tokenService;

    @Autowired
    private AuthenticationService authenticationService;


    @Test
    @DisplayName("Testa se o Token seta sendo gerado adequadamente")
    void generateToken_ShouldGenerateAccessTokenCorrectly() {
        // Criando um usuário
        User user = new User();
        user.setLogin("fulano.silva@email.com");
        user.setPassword("MyPassword123%");
        authenticationService.saveUser(user);

        // Testando a geração de TokensJWT
        String token = tokenService.generateAccessToken(user);
        assertNotNull(token);
    }

    @Test
    @DisplayName("Testa o retorno do Subject")
    void getSubject_ShouldReturnSubject() {
        // Criado um usuário
        User user = new User();
        user.setLogin("fulano.silva@email.com");
        user.setPassword("MyPassowrd123%");
        authenticationService.saveUser(user);

        // Gerando o tokenJWT
        String token = tokenService.generateAccessToken(user);

        // Capturando o Subject da requisição
        TokenData tokenData = tokenService.getSubject(token, "access");

        // Verificando se o subject não é Null
        assertNotNull(tokenData);

        // Verificando se as informações retornadas do Subject estão corretas
        assertEquals(user.getId(), tokenData.id());
        assertEquals(user.getLogin(), tokenData.subject());
    }
}