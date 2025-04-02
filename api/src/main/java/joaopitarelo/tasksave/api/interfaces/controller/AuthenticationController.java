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
import joaopitarelo.tasksave.api.interfaces.dtos.user.outputToken;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.security.NoSuchAlgorithmException;

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

    @PostMapping("/create")
    public ResponseEntity<?> createLogin(@RequestBody @Valid CreateLogin newUser) throws NoSuchAlgorithmException, MessagingException {
        User user = new User(newUser);
        authenticationService.createUser(user);

        String hashEmail = HashUtil.generateHash(user.getLogin());
        String verificationLink = "http://localhost:8080/login/verifyemail/" + user.getId() + "/" + hashEmail;
        emailService.sendHtmlEmail(newUser.login(), "E-mail verification", verificationLink);

        return ResponseEntity.ok().body("User are create successfully");
    }

    @GetMapping("/verifyemail/{id}/{emailHash}")
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

        return ResponseEntity.ok().body(emailHash);
    }

    @PostMapping
    public ResponseEntity<?> doLogin(@RequestBody @Valid DoLogin data) {
        var authenticationToken = new UsernamePasswordAuthenticationToken(data.login(), data.password());
        var authentication = manager.authenticate(authenticationToken);

        User user = authenticationService.loadUserByLogin(data.login());

        if (!user.isUserVerified()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Usuário não verificado, por favor verifique seu e-mail");
        }

        String jwtToken = tokenService.generateToken((User) authentication.getPrincipal());

        return ResponseEntity.ok(new outputToken(jwtToken));
    }
}
