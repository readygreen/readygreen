package com.ddubucks.readygreen.security;

import com.fasterxml.jackson.databind.exc.MismatchedInputException;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.security.SignatureException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class CustomAuthenticationFailureHandler implements AuthenticationFailureHandler {

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception) throws IOException, ServletException {

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
