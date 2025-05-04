package joaopitarelo.tasksave.api.infraestruture.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import joaopitarelo.tasksave.api.application.services.AuthenticationService;
import joaopitarelo.tasksave.api.application.services.TokenService;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.user.TokenData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
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
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String requestPath = request.getRequestURI();

        // Separando o filtro pois o refreshToken não pode cair no mesmo filtro das outras requisições que irão usar o accessToken
        if (requestPath.startsWith("/login")) {
            filterChain.doFilter(request, response);
            return;
        }

        String tokenJWT = getTokenFromRequest(request);

        if (tokenJWT != null) {
            TokenData userInformation = tokenService.getSubject(tokenJWT, true);

            System.out.println(userInformation);
            User user = authenticationService.getUserById(userInformation.id());

            Authentication authentication = new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        // Chamando os próximos filtros, caso o filtro passado tenha sido validado
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
