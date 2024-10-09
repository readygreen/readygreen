package com.ddubucks.readygreen.security;

import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CustomAuthenticationProvider implements AuthenticationProvider {

    private final UserDetailsService userDetailsService;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {

        System.out.println("--CustomAuthenticationProvider.java--");

        UsernamePasswordAuthenticationToken token = (UsernamePasswordAuthenticationToken) authentication;

        System.out.println("token 변환 완료");

        String email = token.getPrincipal().toString();
        String socialId = token.getCredentials().toString();


        // 사용자 자격 증명 검증 로직
        UserDetails userDetails = userDetailsService.loadUserByUsername(email);
        System.out.println("userDetails 검증완료");

        if (isValidSocialId(socialId, userDetails.getPassword())) {
            System.out.println("인증 성공, 인증된 토큰 반환");
            // 인증 성공, 인증된 토큰 반환
            return new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
        }

        throw new BadCredentialsException("Invalid credentials");
    }

    private boolean isValidSocialId(String socialId, String password) {
        return passwordEncoder.matches(socialId, password);
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication);
    }
}
