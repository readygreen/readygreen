package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.SignupRequestDTO;
import com.ddubucks.readygreen.repository.MemberRepository;
import com.ddubucks.readygreen.service.MemberService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import com.ddubucks.readygreen.model.member.Member;
import org.springframework.format.annotation.DateTimeFormat;


import java.time.LocalDate;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
public class MemberController {

    private final MemberService memberService;
    private final MemberRepository memberRepository;

    @PostMapping
    public ResponseEntity<?> signup(@Valid @RequestBody SignupRequestDTO signupRequestDTO) {
        System.out.println("회원가입");
        memberService.signup(signupRequestDTO);
        return ResponseEntity.ok("회원가입 성공");
    }
    @PutMapping("/birth")
    @Operation(summary = "생일 업데이트")
    public ResponseEntity<?> addBirth(@AuthenticationPrincipal UserDetails userDetails, @RequestParam("birthdate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate birthdate) {
        try {
            String username = userDetails.getUsername();
            Member member = memberService.getMemberInfo(userDetails.getUsername());

            member.setBirth(birthdate);
            memberRepository.save(member);

            return ResponseEntity.ok("생일 업데이트 성공");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("생일 업데이트 중 오류발생");
        }
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
