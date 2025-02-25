package joaopitarelo.tasksave.api.application.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTCreationException;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.auth0.jwt.interfaces.JWTVerifier;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.user.TokenData;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Date;

@Service
public class TokenService {

    @Value("${api.security.token.secret}")
    private String secret;

    public String generateToken(User user) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(secret);

            return JWT.create()
                    .withIssuer("TASKSAVE API")
                    .withSubject(user.getLogin())
                    .withClaim("id", user.getId())
                    .withExpiresAt(expirationDate()) // 2h de duração
                    .sign(algorithm);
        } catch (JWTCreationException exception){
            throw new RuntimeException("Error to generate JWT token", exception);
        }
    }

    private Instant expirationDate() {
        return LocalDateTime.now().plusHours(2).toInstant(ZoneOffset.of("-03:00"));
    }

    public TokenData getSubject(String tokenJWT) {
        DecodedJWT decodedJWT;
        try {
            Algorithm algorithm = Algorithm.HMAC256(secret);
            JWTVerifier verifier = JWT.require(algorithm)
                        .withIssuer("TASKSAVE API")
                        .build();

                // JWT decodificado
                decodedJWT = verifier.verify(tokenJWT);

                Long id = decodedJWT.getClaim("id").asLong();
                String subject = decodedJWT.getSubject();

                return new TokenData(id, subject);
        } catch (JWTVerificationException exception){
            throw new RuntimeException("JWT token is invalid or is experied");
        }
    }
}
