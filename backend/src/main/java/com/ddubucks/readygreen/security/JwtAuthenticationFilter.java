package com.ddubucks.readygreen.security;

import com.fasterxml.jackson.databind.exc.MismatchedInputException;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.security.SignatureException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserDetailsService userDetailsService;
    private final CustomAuthenticationFailureHandler authenticationFailureHandler;

    private static String LOGIN_URL = "/auth/login";
    private static String SIGNUP_URL = "/auth";
    private static String SWAGGER_URL = "/swagger-ui/**";
    private static String DOCS_URL = "/v3/api-docs/**";
    private static String HEALTH_URL = "/health/**";
    private static String Link_URL = "/link/check";

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        return new AntPathRequestMatcher(SIGNUP_URL, "POST").matches(request) ||
                new AntPathRequestMatcher(LOGIN_URL, "POST").matches(request) ||
                new AntPathRequestMatcher(SWAGGER_URL).matches(request) ||
                new AntPathRequestMatcher(DOCS_URL).matches(request) ||
                new AntPathRequestMatcher(HEALTH_URL).matches(request) ||
                new AntPathRequestMatcher(Link_URL).matches(request);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            logger.info("JwtAuthenticationFilter.class");
            // 요청에서 JWT 토큰을 추출하는 메서드
            String token = resolveToken(request);

            UserDetails userDetails = userDetailsService.loadUserByUsername(jwtTokenProvider.getEmail(token));

            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(authentication);

            // 다음 필터로 요청 전달
            filterChain.doFilter(request, response);
        } catch (Exception e) {
            handleException(response, e);
        }
    }

    private String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization"); // 헤더에서 토큰 추출
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7); // "Bearer " 이후의 실제 토큰 반환
        }
        return null;
    }

    private void handleException(HttpServletResponse response, Exception exception) throws IOException {
        // 일반 예외 처리 코드
        String errorMessage;
        HttpStatus status;

        if (exception.getCause() instanceof ExpiredJwtException) {
            errorMessage = "JWT token is expired";
            status = HttpStatus.UNAUTHORIZED;
        } else if (exception.getCause() instanceof SignatureException) {
            errorMessage = "Invalid JWT signature";
            status = HttpStatus.UNAUTHORIZED;
        } else if (exception.getCause() instanceof UnsupportedJwtException) {
            errorMessage = "Unsupported JWT token";
            status = HttpStatus.BAD_REQUEST;
        } else if (exception.getCause() instanceof IllegalArgumentException) {
            errorMessage = "Illegal argument provided";
            status = HttpStatus.BAD_REQUEST;
        } else if (exception.getCause() instanceof MismatchedInputException) {
            errorMessage = "Invalid input: " + exception.getCause().getMessage();
            status = HttpStatus.BAD_REQUEST;
        } else if (exception instanceof UsernameNotFoundException) {
            errorMessage = exception.getMessage();
            status = HttpStatus.UNAUTHORIZED;
        } else {
            errorMessage = "Authentication failed";
            status = HttpStatus.BAD_REQUEST;
        }

        response.setStatus(status.value());
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"" + errorMessage + "\"}");
    }
}
