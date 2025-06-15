package joaopitarelo.tasksave.api.interfaces.controller;

import java.security.NoSuchAlgorithmException;
import java.util.Map;

import com.auth0.jwt.exceptions.JWTVerificationException;

import jakarta.transaction.Transactional;
import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;
import org.thymeleaf.TemplateEngine;

import joaopitarelo.tasksave.api.application.services.AuthenticationService;
import joaopitarelo.tasksave.api.application.services.EmailService;
import joaopitarelo.tasksave.api.application.services.TokenService;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.infraestruture.security.HashUtil;
import joaopitarelo.tasksave.api.interfaces.dtos.user.*;


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

    @Value("${app.base-url}")
    private String baseUrl;

    @ResponseBody
    @Transactional
    @PostMapping("/create")
    public ResponseEntity<?> createLogin(@RequestBody @Valid RegisterRequest registerRequest,
                                         UriComponentsBuilder uriBuilder) throws NoSuchAlgorithmException {

        if (authenticationService.loadUserByLogin(registerRequest.login()) != null) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("message","This e-mail has been used for another account"));
        }

        User user = new User(registerRequest);
        authenticationService.saveUser(user);

        String hashEmail = HashUtil.generateHash(user.getLogin());
        String verificationLink = baseUrl + "/login/verifyEmail/" + user.getId() + "/" + hashEmail;

        Map<String, Object> variables = Map.of("verificationUrl", verificationLink);
        emailService.sendVerificationEmail(registerRequest.login(), "E-mail verification", variables);

        var uri = uriBuilder.path("/login/{id}").buildAndExpand(user.getId()).toUri();

        return ResponseEntity.created(uri).body(
                Map.of("user", new OutputUser(user.getId(), user.getLogin(), verificationLink, user.isUserVerified()))
        );
    }

    @GetMapping("/{id}")
    @ResponseBody
    public ResponseEntity<?> getUserById(@PathVariable Long id) throws NoSuchAlgorithmException {
        User user = authenticationService.loadUserById(id);

        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        String hashEmail = HashUtil.generateHash(user.getLogin());
        String verificationLink = baseUrl + "/login/verifyEmail/" + user.getId() + "/" + hashEmail;

        return ResponseEntity.status(HttpStatus.OK)
                .body(Map.of("user", new OutputUser(user.getId(), user.getLogin(), verificationLink, user.isUserVerified())));
    }

    @GetMapping("/verifyEmail/{id}/{emailHash}")
    public String verifyEmail(@PathVariable Long id, @PathVariable String emailHash) throws NoSuchAlgorithmException {
        User user = authenticationService.loadUserById(id);

        if (user == null) {
            return "failed-verification-email-template";
        }

        String userEmail = user.getLogin();
        String userEmailHash = HashUtil.generateHash(userEmail);

        if (!userEmailHash.equals(emailHash)) {
            return "failed-verification-email-template";
        }

        authenticationService.setUserVerified(user);

        return "successfully-verification-email-template";
    }

    @PostMapping
    @ResponseBody
    public ResponseEntity<?> doLogin(@RequestBody @Valid LoginRequest loginRequest) {
        var authenticationToken = new UsernamePasswordAuthenticationToken(loginRequest.login(), loginRequest.password());
        var authentication = manager.authenticate(authenticationToken);

        User user = authenticationService.loadUserByLogin(loginRequest.login());

        if (!user.isUserVerified()) {
            return ResponseEntity.status(HttpStatus.PRECONDITION_REQUIRED)
                    .body(Map.of("message", "e-mail not verified"));
        }

        String accessToken = tokenService.generateAccessToken((User) authentication.getPrincipal());
        String refreshToken = tokenService.generateRefreshToken((User) authentication.getPrincipal());

        return ResponseEntity.ok(new OutputToken(accessToken, refreshToken));
    }

    @PostMapping("/refresh")
    @ResponseBody
    public ResponseEntity<?> refreshToken(@RequestBody @Valid RefreshToken data) {
        if (!tokenService.isRefreshTokenValid(data.refreshToken())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message","invalid or expired refresh token"));
        }

        TokenData userInfo = tokenService.getSubject(data.refreshToken(), "refresh");
        User user = authenticationService.loadUserById(userInfo.id());

        String newAccessToken = tokenService.generateAccessToken(user);
        String newRefreshToken = tokenService.generateRefreshToken(user);

        return ResponseEntity.ok(new OutputToken(newAccessToken, newRefreshToken));
    }

    // Recuperação de senha 1° - Envio do e-mail de recuperação
    @ResponseBody
    @PostMapping("/rescue")
    public ResponseEntity<?> rescueUser(@RequestBody @Valid RescueLogin data) {
        // Verifica se existe algum usuário com esse login(email)
        User user = authenticationService.getUserByLogin(data.email());

        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "user not found"));
        }

        String rescueJwtToken = tokenService.generateRescueToken(user);

        String link = baseUrl + "/login/rescue/redirect-app?token=" + rescueJwtToken;

        Map<String, Object> variables = Map.of(
                "rescueUrl", link
        );

        emailService.sendRescueEmail(user.getLogin(), "Recuperação de senha", variables);
        return ResponseEntity.status(HttpStatus.OK)
                .body(Map.of("token", rescueJwtToken, "message", "E-mail enviado com sucesso"));

    }

    // Recuperação de senha 2° - validação do JWT e redirecionamento para o App
    @GetMapping("/rescue/redirect-app")
    public String redirectForApp(@RequestParam String token, Model model) {
        TokenData userInfo;

        try {
            userInfo = tokenService.getSubject(token, "rescue");
        } catch (JWTVerificationException e) {
            return "rescue-login-unauthorized";
        }

        User user = authenticationService.loadUserById(userInfo.id());

        model.addAttribute("rescueUrl", "tasksave://rescue-login?token=" + token);
        model.addAttribute("emailUser", user.getLogin());

        return "rescue-login-redirect-template";  // nome do template HTML
    }

    // Recuperação de senha 3° - troca da senha do usuário - vai para o APP
    @PutMapping("/rescue")
    @Transactional
    public ResponseEntity<?> updateLogin(@RequestBody @Valid ChangePassword data) {
        TokenData tokenData;
        try {
            tokenData = tokenService.getSubject(data.token(), "rescue");
        } catch (JWTVerificationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Token is invalid or expired"));
        }

        User user = authenticationService.loadUserById(tokenData.id());
        authenticationService.changeUserPassword(user, data.newPassword());

        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }


}
