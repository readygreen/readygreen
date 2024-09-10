package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.SignupRequest;
import com.ddubucks.readygreen.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api")
public class MemberController {

    private final MemberService memberService;

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequest signupRequest) {
        System.out.println("회원가입");
        memberService.signup(signupRequest);
        return ResponseEntity.ok("회원가입 성공");
    }
}
