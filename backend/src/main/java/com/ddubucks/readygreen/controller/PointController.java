package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.PointRequestDTO;
import com.ddubucks.readygreen.model.Point;
import com.ddubucks.readygreen.service.MemberService;
import com.ddubucks.readygreen.service.PointService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/point")
public class PointController {
    private final MemberService memberService;
    private final PointService pointService;

    @GetMapping
    public ResponseEntity<Integer> getPoint(@AuthenticationPrincipal UserDetails userDetails){
        Integer point = memberService.getPoint(userDetails);
        return ResponseEntity.ok(point);
    }
    @PostMapping
    public ResponseEntity<String> addPoint(@AuthenticationPrincipal UserDetails userDetails, @RequestBody PointRequestDTO pointRequestDTO) {
        pointService.addPoint(userDetails.getUsername(), pointRequestDTO);
        return ResponseEntity.ok("포인트가 성공적으로 추가되었습니다.");
    }
    @GetMapping("/list")
    public ResponseEntity<List<Point>> getPoints(@AuthenticationPrincipal UserDetails userDetails) {
        List<Point> points = pointService.getPointsByMember(userDetails.getUsername());
        return ResponseEntity.ok(points);
    }
}
