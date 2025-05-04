package joaopitarelo.tasksave.api.interfaces.controller;

import jakarta.mail.MessagingException;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.application.services.AuthenticationService;
import joaopitarelo.tasksave.api.application.services.EmailService;
import joaopitarelo.tasksave.api.application.services.TokenService;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.infraestruture.security.HashUtil;
import joaopitarelo.tasksave.api.interfaces.dtos.user.CreateLogin;
import joaopitarelo.tasksave.api.interfaces.dtos.user.DoLogin;
import joaopitarelo.tasksave.api.interfaces.dtos.user.TokenData;
import joaopitarelo.tasksave.api.interfaces.dtos.user.OutputToken;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.security.NoSuchAlgorithmException;
import java.util.Map;

@RestController
@RequestMapping("login")
public class AuthenticationController {

    @Autowired
    private AuthenticationManager manager;
    @Autowired
    private TokenService tokenService;
    @Autowired
    private AuthenticationService authenticationService;
    @Autowired
    private EmailService emailService;
    @Autowired
    TemplateEngine templateEngine;

    @PostMapping("/create")
    public ResponseEntity<?> createLogin(@RequestBody @Valid CreateLogin newUser) throws NoSuchAlgorithmException, MessagingException {

        if (authenticationService.loadUserByLogin(newUser.login()) != null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Este email já esta sendo usado em outra conta");
        }

        User user = new User(newUser);
        // Atribuí o id e salva no banco
        authenticationService.createUser(user);

        String hashEmail = HashUtil.generateHash(user.getLogin());
        String verificationLink = "http://localhost:8080/login/verifyemail/" + user.getId() + "/" + hashEmail;

        Map<String, Object> variables = Map.of(
        "verificationUrl", verificationLink
        );

        emailService.sendHtmlEmail(newUser.login(), "E-mail verification", variables);

        return ResponseEntity.ok().body("User are create successfully");
    }

    @GetMapping("/verifyemail/{id}/{emailHash}")
    @ResponseBody
    public ResponseEntity<?> verifyEmail(@PathVariable Long id, @PathVariable String emailHash) throws NoSuchAlgorithmException {
        User user = authenticationService.getUserById(id);

        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Usuário não encontrado");
        }

        String userEmail = user.getLogin();
        String userEmailHash = HashUtil.generateHash(userEmail);

        if (!userEmailHash.equals(emailHash)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Hashes não batem");
        }

        authenticationService.setUserVerified(user);

        Context context = new Context();
        String htmlContent = templateEngine.process("verification-succefull-template", context);

        return ResponseEntity.ok().body(htmlContent);
    }

    @PostMapping
    public ResponseEntity<?> doLogin(@RequestBody @Valid DoLogin data) {
        var authenticationToken = new UsernamePasswordAuthenticationToken(data.login(), data.password());
        var authentication = manager.authenticate(authenticationToken);

        User user = authenticationService.loadUserByLogin(data.login());

        if (!user.isUserVerified()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Usuário não verificado, por favor verifique seu e-mail");
        }

        String accessToken = tokenService.generateAccessToken((User) authentication.getPrincipal());
        String refreshToken = tokenService.generateRefreshToken((User) authentication.getPrincipal());

        return ResponseEntity.ok(new OutputToken(accessToken, refreshToken));
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> refreshToken(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");

        if (!tokenService.isRefreshTokenValid(refreshToken)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Refresh token inválido ou expirado");
        }

        TokenData refreshTokenUserInfo = tokenService.getSubject(refreshToken, false);
        User user = authenticationService.loadUserByLogin(refreshTokenUserInfo.subject());

        String newAccessToken = tokenService.generateAccessToken(user);
        String newRefreshToken = tokenService.generateRefreshToken(user);

        return ResponseEntity.ok(new OutputToken(newAccessToken, newRefreshToken));
    }
}
