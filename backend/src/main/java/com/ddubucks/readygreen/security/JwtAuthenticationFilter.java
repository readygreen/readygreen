package com.ddubucks.readygreen.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
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

    private static String LOGIN_URL = "/api/*/auth/login";
    private static String SIGNUP_URL = "/api/*/auth";

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        return new AntPathRequestMatcher(SIGNUP_URL, "POST").matches(request) ||
                new AntPathRequestMatcher(LOGIN_URL, "POST").matches(request);
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
        } catch (AuthenticationException e) {
            authenticationFailureHandler.onAuthenticationFailure(request, response, e);
        }
    }

    private String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization"); // 헤더에서 토큰 추출
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7); // "Bearer " 이후의 실제 토큰 반환
        }
        return null;
    }
}
