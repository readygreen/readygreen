package com.ddubucks.readygreen.security;


import com.ddubucks.readygreen.dto.AuthRequestDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.SneakyThrows;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

public class CustomAuthenticationFilter extends AbstractAuthenticationProcessingFilter {

    private static final String LOGIN_URL = "/api/*/auth/login";

    private ObjectMapper objectMapper = new ObjectMapper();

    public CustomAuthenticationFilter(
            AuthenticationManager authenticationManager,
            AuthenticationSuccessHandler authenticationSuccessHandler,
            AuthenticationFailureHandler authenticationFailureHandler
    ) {
        super(new AntPathRequestMatcher(LOGIN_URL, "POST")); //login 요청만 필터 적용
        setAuthenticationManager(authenticationManager);
        setAuthenticationSuccessHandler(authenticationSuccessHandler);
        setAuthenticationFailureHandler(authenticationFailureHandler);
    }

    @SneakyThrows
    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response) throws AuthenticationException {

        System.out.println("--CustomAuthenticationFilter.java--");
        // 요청(Request)에서 전달된 JSON 데이터를 AuthDto 객체로 변환
        AuthRequestDTO authRequestDto = objectMapper.readValue(request.getReader(), AuthRequestDTO.class);

        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                authRequestDto.getEmail(), authRequestDto.getSocialId()
        );

        System.out.println("authenticationToken 생성 완료");

        // AuthenticationManager를 통해 인증을 시도하고, 인증 결과를 반환
        return getAuthenticationManager().authenticate(authenticationToken);
    }

}
