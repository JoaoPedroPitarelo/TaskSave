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
import java.util.Date;

@Service
public class TokenService {

    @Value("${api.security.token.accessSecret}") // carrega do application.properties
    private String accessSecret;

    @Value("${api.security.token.refreshSecret}") // carrega do application.properties
    private String refreshSecret;

    public String generateAccessToken(User user) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(accessSecret);

            return JWT.create()
                    .withIssuer("TASKSAVE API")
                    .withSubject(user.getLogin())
                    .withClaim("id", user.getId())
                    .withClaim("tokenType", "access")
                    .withExpiresAt(new Date(System.currentTimeMillis() + 1000L * 60 * 10)) // 2h de duração
                    .sign(algorithm);
        } catch (JWTCreationException exception){
            throw new RuntimeException("Error to generate JWT accessToken", exception);
        }
    }

    public String generateRefreshToken(User user) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(refreshSecret);

            return JWT.create()
                    .withIssuer("TASKSAVE API")
                    .withSubject(user.getLogin())
                    .withClaim("id", user.getId())
                    .withClaim("tokenType", "refresh")
                    .withExpiresAt(new Date(System.currentTimeMillis() + 1000L * 60 * 60 * 24 * 10)) // 10 dias de duração
                    .sign(algorithm);
        } catch (JWTCreationException exception){
            throw new RuntimeException("Error to generate JWT RefreshToken", exception);
        }
    }

    public boolean isRefreshTokenValid(String refreshToken) {
        DecodedJWT decodedJWT;
        try {
            Algorithm algorithm = Algorithm.HMAC256(refreshSecret);
            JWTVerifier verifier = JWT.require(algorithm)
                    .withIssuer("TASKSAVE API")
                    .build();

            decodedJWT = verifier.verify(refreshToken);

            // Bloqueando os token do tipo accessToken
            if (decodedJWT.getClaim("tokenType").asString().equals("access")) return false;

            return true;
        } catch (JWTVerificationException exception) {
            return false;
        }
    }

    public TokenData getSubject(String tokenJWT, boolean isAccessToken) {
        DecodedJWT decodedJWT;
        try {
            Algorithm algorithm;

            if (isAccessToken) {
                algorithm = Algorithm.HMAC256(accessSecret);
            } else {
                algorithm = Algorithm.HMAC256(refreshSecret);
            }

            JWTVerifier verifier = JWT.require(algorithm)
                        .withIssuer("TASKSAVE API")
                        .build();

                // JWT decodificado
                decodedJWT = verifier.verify(tokenJWT);

                Long id = decodedJWT.getClaim("id").asLong();
                String subject = decodedJWT.getSubject();

                return new TokenData(id, subject);
        } catch (JWTVerificationException exception){
            throw new RuntimeException("JWT token is invalid or are experied");
        }
    }
}
