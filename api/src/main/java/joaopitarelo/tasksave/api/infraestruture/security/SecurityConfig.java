package joaopitarelo.tasksave.api.infraestruture.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private SecurityFilter securityFilter;

    @Autowired
    private CustomAccessDeniedHandler accessDeniedHandler;

    // csrf = é um tipo de ataque que pode ser aplicado em api statefull, que utilizado Sessões
    // Como nossa api é do tipo stateless, e ira usar tokens, não há a necessidade de continuarmos utilizando
    // essa camada de segurança que vem por padrão, pois os tokens já nos protegem desse tipo de ataque

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception{
       http
           .csrf(AbstractHttpConfigurer::disable) // Desabilitando a proteção contra ataques csrf (statefull)
           .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // Definindo a sesssão como stateless
           .exceptionHandling(e -> e.accessDeniedHandler(accessDeniedHandler).
                   authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)))
           .authorizeHttpRequests(req -> {
               req.requestMatchers("/login").permitAll();
               req.requestMatchers("/login/*").permitAll();
               req.requestMatchers("/login/create").permitAll();
               req.requestMatchers("/login/verifyEmail/**").permitAll();
               req.requestMatchers("/login/refresh").permitAll();
               req.requestMatchers("/login/rescue").permitAll();
               req.requestMatchers("/login/rescue/redirect-app").permitAll();
               req.anyRequest().authenticated();
           })
           .addFilterBefore(securityFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception{
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
