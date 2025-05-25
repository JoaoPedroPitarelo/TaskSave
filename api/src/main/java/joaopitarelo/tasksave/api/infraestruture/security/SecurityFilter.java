package joaopitarelo.tasksave.api.infraestruture.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import joaopitarelo.tasksave.api.application.services.AuthenticationService;
import joaopitarelo.tasksave.api.application.services.TokenService;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.user.TokenData;
import org.jetbrains.annotations.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component // Carrega como um componente "genêrico"
public class SecurityFilter extends OncePerRequestFilter { // "paraCadaRequisiçãoFiltro"

    @Autowired
    private TokenService tokenService;
    private final AuthenticationService authenticationService;

    // @Lazy faz com que o securityFilter só seja intanciado quando necessário, evitando o ciclo de dependências
    // Exemplo: serviceA -> serviceB | serviceB -> serviceA
    public SecurityFilter(@Lazy AuthenticationService authenticationService) {
        this.authenticationService = authenticationService;
    }


    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    @NotNull  HttpServletResponse response,
                                    @NotNull  FilterChain filterChain) throws ServletException, IOException {
        String path = request.getRequestURI();

        // Libera tudo caso a rota comece com "/login"
        if (path.startsWith("/login")) {
            filterChain.doFilter(request, response);
            return;
        }

        // Caso não seja alguma rota que comece com "/login" e não seja informado o token
        String token = getTokenFromRequest(request);
        if (token == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            TokenData data = tokenService.getSubject(token, "access");
            User user = authenticationService.getUserById(data.id());
            var auth = new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(auth);
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // Caso dê tudo certo passa para os filtros restantes
        filterChain.doFilter(request, response);
    }


    private String getTokenFromRequest(HttpServletRequest request) {
        String authorizationHeader = request.getHeader("Authorization");

        if (authorizationHeader != null) {
            return authorizationHeader.replace("Bearer ", "").trim();
        }
        return null;
    }
}
