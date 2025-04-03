package joaopitarelo.tasksave.api.application.services;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class EmailServiceTest {

    @Autowired
    private EmailService emailService;

    @Test
    void sendEmailTest() {
        emailService.SendEmailTest("jpspitarelo14@gmail.com", "Teste", "<h1>TESTE</h1>");
    }
}