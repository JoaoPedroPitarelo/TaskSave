package joaopitarelo.tasksave.api.application.services;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

@Service
public class EmailService {
    @Autowired
    private JavaMailSender emailSender;

    @Autowired
    private TemplateEngine templateEngine;

    public EmailService() {
    }

    public void SendEmailTest(String to, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject(subject);
        message.setText(text);
        message.setFrom("noreply.tasksaveapp@gmail.com");

        emailSender.send(message);
    }

    public void sendHtmlEmail(String to, String subject, Map<String, Object> variables) throws MessagingException, IOException {
        MimeMessage message = emailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setTo(to);
        helper.setSubject(subject);
        helper.setFrom("noreply.tasksaveapp@gmail.com");

        Context context = new Context();
        context.setVariables(variables);
        String htmlContent = templateEngine.process("email-verification-template", context);

        helper.setText(htmlContent, true);

        InputStream image = getClass().getClassLoader().getResourceAsStream("static/images/logo.png");

        if (image == null) {
            throw new RuntimeException("Imagem não encontrada para o envio do e-mail");
        }
        helper.addInline("logo", new ByteArrayResource(image.readAllBytes()), "image/png");

        emailSender.send(message);
    }
}
