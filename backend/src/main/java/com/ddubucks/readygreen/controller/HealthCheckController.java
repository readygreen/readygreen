package com.ddubucks.readygreen.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;

@RestController
@RequestMapping("/health")
@Tag(name = "Health Check", description = "헬스 체크 코드")
public class HealthCheckController {

    private final Environment env;
    private final DataSource dataSource;  // MySQL 연결용 DataSource
    private final RedisTemplate<String, String> redisTemplate;  // Redis 연결 확인용 RedisTemplate

    @Autowired
    public HealthCheckController(Environment env, DataSource dataSource, RedisTemplate<String, String> redisTemplate) {
        this.env = env;
        this.dataSource = dataSource;
        this.redisTemplate = redisTemplate;
    }

    @GetMapping
    @Operation(summary = "Health Check", description = "헬스 체크")
    public ResponseEntity<String> healthCheck() {
        String dbUsername = env.getProperty("DB_USERNAME");
        String message = "Server is running! Connected as: " + dbUsername + "\n";

        // MySQL 연결 확인
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(2)) {  // 2초 이내에 연결 확인
                message += "MySQL connection is valid.\n";
            } else {
                message += "MySQL connection is invalid.\n";
            }
        } catch (Exception e) {
            message += "Failed to connect to MySQL: " + e.getMessage() + "\n";
        }

        // Redis 연결 확인
        try {
            redisTemplate.opsForValue().set("healthCheck", "OK");  // 간단한 키-값 저장
            String redisValue = redisTemplate.opsForValue().get("healthCheck");
            if ("OK".equals(redisValue)) {
                message += "Redis connection is valid.\n";
            } else {
                message += "Redis connection is invalid.\n";
            }
        } catch (Exception e) {
            message += "Failed to connect to Redis: " + e.getMessage() + "\n";
        }

        return new ResponseEntity<>(message, HttpStatus.OK);
    }
}
