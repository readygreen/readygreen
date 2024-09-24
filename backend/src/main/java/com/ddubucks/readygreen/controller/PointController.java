package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/point")
public class PointController {
    private final MemberService memberService;

    @GetMapping
    public ResponseEntity<Integer> getPoint(@AuthenticationPrincipal UserDetails userDetails){
        Integer point = memberService.getPoint(userDetails);
        return ResponseEntity.ok(point);
    }
}
