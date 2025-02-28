package joaopitarelo.tasksave.api.interfaces.controller;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.application.services.AuthenticationService;
import joaopitarelo.tasksave.api.application.services.TokenService;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.user.CreateLogin;
import joaopitarelo.tasksave.api.interfaces.dtos.user.DoLogin;
import joaopitarelo.tasksave.api.interfaces.dtos.user.outputToken;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.UriComponentsBuilder;

@RestController
@RequestMapping("login")
public class AuthenticationController {

    @Autowired
    private AuthenticationManager manager;
    @Autowired
    private TokenService tokenService;
    @Autowired
    private AuthenticationService authenticationService;

    @PostMapping("/create")
    public ResponseEntity<?> createLogin(@RequestBody @Valid CreateLogin newUser) {
        User user = new User(newUser);
        authenticationService.createUser(user);

        return ResponseEntity.ok().body("User are create successfully");
    }

    @PostMapping
    public ResponseEntity<?> doLogin(@RequestBody @Valid DoLogin data) {
        var authenticationToken = new UsernamePasswordAuthenticationToken(data.login(), data.password());
        var authentication = manager.authenticate(authenticationToken);

        String jwtToken = tokenService.generateToken((User) authentication.getPrincipal());

        return ResponseEntity.ok(new outputToken(jwtToken));
    }
}
