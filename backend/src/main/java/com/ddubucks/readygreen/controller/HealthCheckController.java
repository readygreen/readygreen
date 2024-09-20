package com.ddubucks.readygreen.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/health")
@Tag(name = "Health Check", description = "APIs for checking the server health")
public class HealthCheckController {

    @GetMapping("/")
    @Operation(summary = "Health Check", description = "Checks if the server is running and returns a confirmation message.")
    public ResponseEntity<String> healthCheck() {
        return new ResponseEntity<>("Server is running!", HttpStatus.OK);
    }
}
