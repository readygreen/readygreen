package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.SignupRequestDTO;
import com.ddubucks.readygreen.service.MemberService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import com.ddubucks.readygreen.model.member.Member;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
public class MemberController {

    private final MemberService memberService;

    @PostMapping
    public ResponseEntity<?> signup(@Valid @RequestBody SignupRequestDTO signupRequestDTO) {
        System.out.println("회원가입");
        memberService.signup(signupRequestDTO);
        return ResponseEntity.ok("회원가입 성공");
    }

    @DeleteMapping
    public ResponseEntity<?> delete(@AuthenticationPrincipal UserDetails userDetails) {
        memberService.delete(userDetails.getUsername());
        return ResponseEntity.ok("탈퇴 성공");
    }

    @GetMapping
    public ResponseEntity<Member> getMemberInfo(@AuthenticationPrincipal UserDetails userDetails) {
        System.out.println(userDetails.getUsername());
        Member member = memberService.getMemberInfo(userDetails.getUsername());
        return ResponseEntity.ok(member);
    }
}
