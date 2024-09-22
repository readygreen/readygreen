package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.SignupRequest;
import com.ddubucks.readygreen.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
public class MemberController {

    private final MemberService memberService;

    @PostMapping
    public ResponseEntity<?> signup(@RequestBody SignupRequest signupRequest) {
        System.out.println("회원가입");
        memberService.signup(signupRequest);
        return ResponseEntity.ok("회원가입 성공");
    }

    @DeleteMapping
    public ResponseEntity<?> delete(@AuthenticationPrincipal UserDetails userDetails) {
        memberService.delete(userDetails.getUsername());
        return ResponseEntity.ok("탈퇴 성공");
    }
}
