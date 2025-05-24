package joaopitarelo.tasksave.api.application.services;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import joaopitarelo.tasksave.api.infraestruture.exceptions.SendingEmailException;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
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
import java.net.SocketException;
import java.util.Map;

@Service
@AllArgsConstructor
@NoArgsConstructor
public class EmailService {

    @Autowired
    private JavaMailSender emailSender;
    @Autowired
    private TemplateEngine templateEngine;

    public void SendEmailTest(String to, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject(subject);
        message.setText(text);
        message.setFrom("noreply.tasksaveapp@gmail.com");

        emailSender.send(message);
    }

    public void sendVerificationEmail(String to, String subject, Map<String, Object> variables) {
        try {
            MimeMessage message = emailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(to);
            helper.setSubject(subject);
            helper.setFrom("noreply.tasksaveapp@gmail.com");

            Context context = new Context();
            context.setVariables(variables);
            String htmlContent = templateEngine.process("verification-email-template", context);

            helper.setText(htmlContent, true);

            InputStream image = getClass().getClassLoader().getResourceAsStream("static/images/logo.png");

            if (image == null) {
                throw new RuntimeException("Imagem não encontrada para o envio do e-mail");
            }
            helper.addInline("logo", new ByteArrayResource(image.readAllBytes()), "image/png");

            emailSender.send(message);
        } catch (MessagingException | IOException e) {
            throw new SendingEmailException("error sending email", e);
        }
    }

    public void sendRescueEmail(String to, String subject, Map<String, Object> variables) {
        try {
            MimeMessage message = emailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(to);
            helper.setSubject(subject);
            helper.setFrom("noreply.tasksaveapp@gmail.com");

            Context context = new Context();
            context.setVariables(variables);
            String htmlContent = templateEngine.process("rescue-login-email-template", context);

            helper.setText(htmlContent, true);

            InputStream image = getClass().getClassLoader().getResourceAsStream("static/images/logo.png");

            if (image == null) {
                throw new RuntimeException("Imagem não encontrada para o envio do e-mail");
            }

            helper.addInline("logo", new ByteArrayResource(image.readAllBytes()), "image/png");

            emailSender.send(message);
        } catch (MessagingException | IOException e) {
            throw new SendingEmailException("erro sending email", e);
        }
    }
}
