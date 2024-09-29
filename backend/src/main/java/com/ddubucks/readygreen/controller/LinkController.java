package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.service.RedisService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/link")
@Tag(name = "link devices", description = "스마트폰 워치 연동")
@AllArgsConstructor
public class LinkController {

    private final RedisService redisService;

    @PostMapping
    @Operation(summary = "link devices", description = "스마트폰에서 인증번호 저장")
    public ResponseEntity<String> saveAuthNumber(@AuthenticationPrincipal UserDetails userDetails, @RequestParam String authNumber, @Parameter(hidden = true) @RequestHeader("Authorization") String accessToken){
        String token = accessToken.replace("Bearer ","");
        System.out.println(token);
        redisService.saveWithTimeout(userDetails.getUsername()+authNumber, token);
        return ResponseEntity.ok("인증번호 저장 성공");
    }

    @GetMapping("check")
    @Operation(summary = "check auth", description = "워치에서 인증번호 일치하는지 확인")
    public ResponseEntity<Object> checkAuth(@RequestParam String email, @RequestParam String authNumber) {

        Object token = redisService.find(email+authNumber);
        if (token!=null) {
            return ResponseEntity.ok(token);
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("인증 실패");
        }
    }
}
