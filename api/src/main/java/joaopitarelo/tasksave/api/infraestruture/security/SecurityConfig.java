package joaopitarelo.tasksave.api.infraestruture.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired // Injetando o nosso filtro de autenticação
    private SecurityFilter securityFilter;

    // csrf = é um tipo de ataque que pode ser aplicado em api statefull, que utilizado Sessões
    // Como nossa api é do tipo stateless, e ira usar tokens, não há a necessidade de continuarmos utilizando
    // essa camada de segurança que vem por padrão, pois os tokens já nos protegem desse tipo de ataque

    @Bean // Expõe o retorno desse métode para o Spring, podendo ser utilizado em outras camadas
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception{
       http
           .csrf(csrf -> csrf.disable()) // Desabilitando a proteção contra ataques csrf (statefull)
           .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // Definindo a sesssão como stateless
           .authorizeHttpRequests(req -> {
               req.requestMatchers("/login").permitAll(); // liberando todas as requisições para /login
               req.requestMatchers("/login/create").permitAll();
               req.requestMatchers("/login/verifyemail/**").permitAll();
               req.anyRequest().authenticated(); // todas as outra precisam estar autenticadas
           })
           .addFilterBefore(securityFilter, UsernamePasswordAuthenticationFilter.class); // use securityFilter antes de ...

        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception{
        return config.getAuthenticationManager();
    }

    // Dizendo ao Spring que estamos usando o BCrypt como algoritmos de criptografia de senhas
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

}
