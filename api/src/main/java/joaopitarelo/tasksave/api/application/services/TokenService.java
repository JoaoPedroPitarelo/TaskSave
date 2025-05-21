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

import java.security.NoSuchAlgorithmException;
import java.util.Date;

@Service
public class TokenService {

    @Value("${api.security.token.accessSecret}") // carrega do application.properties
    private String accessSecret;

    @Value("${api.security.token.refreshSecret}") // carrega do application.properties
    private String refreshSecret;

    @Value("${api.security.token.rescueSecret}") // carrega do application.properties
    private String rescueSecret;


    public String generateAccessToken(User user) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(accessSecret);

            return JWT.create()
                    .withIssuer("TASKSAVE API")
                    .withSubject(user.getLogin())
                    .withClaim("id", user.getId())
                    .withClaim("tokenType", "access")
                    .withExpiresAt(new Date(System.currentTimeMillis() + 1000L * 60 * 30)) // 30 minutos
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

    private Algorithm getAlgorithm(String tokenType) {

        switch (tokenType) {
            case "access" -> {
                return Algorithm.HMAC256(accessSecret);
            }
            case "refresh" -> {
                return Algorithm.HMAC256(refreshSecret);
            }
            case "rescue" -> {
                return Algorithm.HMAC256(rescueSecret);
            }
            default -> {
                throw new RuntimeException("Type is invalid");
            }
        }
    }

    public TokenData getSubject(String tokenJWT, String type) {
        DecodedJWT decodedJWT;

        try {

            JWTVerifier verifier = JWT.require(getAlgorithm(type))
                        .withIssuer("TASKSAVE API")
                        .build();

                // JWT decodificado
                decodedJWT = verifier.verify(tokenJWT);

                Long id = decodedJWT.getClaim("id").asLong();
                String subject = decodedJWT.getSubject();

                return new TokenData(id, subject);
        } catch (JWTVerificationException exception){
            throw new JWTVerificationException("JWT token is invalid or are experied");
        }
    }

    public String generateRescueToken(User user) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(rescueSecret);

            return JWT.create()
                    .withIssuer("TASKSAVE API")
                    .withSubject(user.getLogin())
                    .withClaim("id", user.getId())
                    .withClaim("tokenType", "rescue")
                    .withExpiresAt(new Date(System.currentTimeMillis() + 1000L * 60 * 15)) // 15 min
                    .sign(algorithm);
        } catch (JWTCreationException exception){
            throw new RuntimeException("Error to generate JWT accessToken", exception);
        }
    }
}
