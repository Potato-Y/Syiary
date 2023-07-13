package io.potatoy.syiary.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.web.SecurityFilterChain;

import static org.springframework.boot.autoconfigure.security.servlet.PathRequest.toH2Console;

@EnableWebSecurity
@EnableMethodSecurity
@Configuration
@RequiredArgsConstructor
public class WebSecurityConfig {

    // 스프링 시큐리티 기능 비활성화
    @Bean
    public WebSecurityCustomizer configure() {
        return web -> web.ignoring()
                .requestMatchers(toH2Console())
                .requestMatchers("/img/**", "/css/**", "/js/**");
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
                .authorizeHttpRequests(authz -> authz
                        .requestMatchers("/", "/login", "/signup").permitAll()
                        .anyRequest().authenticated())
                .build();
    }
}
