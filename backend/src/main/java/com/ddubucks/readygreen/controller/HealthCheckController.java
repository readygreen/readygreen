package com.ddubucks.readygreen.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/health")
@Tag(name = "Health Check", description = "헬스 체크 코드")
public class HealthCheckController {

    private final Environment env;

    @Autowired
    public HealthCheckController(Environment env) {
        this.env = env;
    }

    @GetMapping("/")
    @Operation(summary = "Health Check", description = "헬스 체크")
    public ResponseEntity<String> healthCheck() {
        // 예시로 DB_USERNAME 환경 변수를 가져와서 출력
        String dbUsername = env.getProperty("DB_USERNAME");

        String message = "Server is running! Connected as: " + dbUsername;

        return new ResponseEntity<>(message, HttpStatus.OK);
    }
}
