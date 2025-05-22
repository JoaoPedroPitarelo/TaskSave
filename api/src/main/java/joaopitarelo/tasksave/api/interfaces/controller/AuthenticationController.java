package joaopitarelo.tasksave.api.interfaces.controller;

import com.auth0.jwt.exceptions.JWTVerificationException;
import jakarta.mail.MessagingException;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.application.services.AuthenticationService;
import joaopitarelo.tasksave.api.application.services.EmailService;
import joaopitarelo.tasksave.api.application.services.TokenService;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.infraestruture.security.HashUtil;
import joaopitarelo.tasksave.api.interfaces.dtos.user.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.Map;

@Controller
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

    @ResponseBody
    @PostMapping("/create")
    public ResponseEntity<?> createLogin(@RequestBody @Valid CreateLogin newUser,
                                         UriComponentsBuilder uriBuilder) throws NoSuchAlgorithmException, MessagingException, IOException {

        if (authenticationService.loadUserByLogin(newUser.login()) != null) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Este email já esta sendo usado em outra conta");
        }

        User user = new User(newUser);
        // Atribuí o id e salva no banco
        authenticationService.createUser(user);

        String hashEmail = HashUtil.generateHash(user.getLogin());
        // TODO quando for para produção esse link tem que ser dinâmico da onde estiver rodando a API
        String verificationLink = "http://localhost:8080/login/verifyemail/" + user.getId() + "/" + hashEmail;

        Map<String, Object> variables = Map.of(
        "verificationUrl", verificationLink
        );

        emailService.sendVerificationEmail(newUser.login(), "E-mail verification", variables);

        var uri = uriBuilder.path("/login/{id}").buildAndExpand(user.getId()).toUri();

        return ResponseEntity.created(uri).body(new OutputUser(user.getId(), user.getLogin(),verificationLink, user.isUserVerified()));
    }

    @GetMapping("/{id}")
    @ResponseBody
    public ResponseEntity<?> getById(@PathVariable Long id) throws NoSuchAlgorithmException {
        User user = authenticationService.getUserById(id);

        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        String hashEmail = HashUtil.generateHash(user.getLogin());
        // TODO quando for para produção esse link tem que ser dinâmico da onde estiver rodando a API
        String verificationLink = "http://localhost:8080/login/verifyemail/" + user.getId() + "/" + hashEmail;

        return ResponseEntity.status(HttpStatus.OK).body(new OutputUser(user.getId(), user.getLogin(), verificationLink, user.isUserVerified()));
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
        String htmlContent = templateEngine.process("successfully-verification-email-template", context);

        return ResponseEntity.ok().body(htmlContent);
    }

    @PostMapping
    @ResponseBody
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
    @ResponseBody
    public ResponseEntity<?> refreshToken(@RequestBody Map<String, String> request) { // TODO fazer um DTO para isso
        String refreshToken = request.get("refreshToken");

        if (!tokenService.isRefreshTokenValid(refreshToken)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Refresh token inválido ou expirado");
        }

        TokenData refreshTokenUserInfo = tokenService.getSubject(refreshToken, "refresh");
        User user = authenticationService.loadUserByLogin(refreshTokenUserInfo.subject());

        String newAccessToken = tokenService.generateAccessToken(user);
        String newRefreshToken = tokenService.generateRefreshToken(user);

        return ResponseEntity.ok(new OutputToken(newAccessToken, newRefreshToken));
    }

    // Recuperação de senha 1° - Envio do e-mail de recuperação
    @PostMapping("/rescue")
    @ResponseBody
    public ResponseEntity<?> rescueUser(@RequestBody @Valid RescueLogin data) throws MessagingException, IOException{
        // Verifica se existe algum usuário com esse login(email)
        User user = authenticationService.getUserByLogin(data.email());

        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }

        String rescueJwtToken = tokenService.generateRescueToken(user);

        // Quem irá receber esse link é o app Flutter
        String link = "http://localhost:8080/login/rescue/open-app?token=" + rescueJwtToken;

        Map<String, Object> variables = Map.of(
                "rescueUrl", link
        );

        try {
            emailService.sendRescueEmail(user.getLogin(), "Recuperação de senha", variables);
            return ResponseEntity.status(HttpStatus.OK).body(Map.of("message", "E-mail enviado com sucesso"));
        } catch (MessagingException | IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Error during send the e-mail",
                                 "error", e));
        }
    }

    // Recuperação de senha 2° - validacao do JWT e redirecionamento para o App
    @GetMapping("/rescue/open-app")
    public String redirectForApp(@RequestParam String token, Model model) {
        TokenData userInfo;

        try {
            userInfo = tokenService.getSubject(token, "rescue");
        } catch (JWTVerificationException e) {
            // TODO fazer o template para caso não for autorizado
            return "rescue-login-unauthorized";
        }

        System.out.println(userInfo);
        User user = authenticationService.getUserById(userInfo.id());

        model.addAttribute("rescueUrl", "tasksave://rescue-login?token=" + token);
        model.addAttribute("emailUser", user.getLogin());

        return "rescue-login-redirect-template";  // nome do template HTML
    }
    

}
