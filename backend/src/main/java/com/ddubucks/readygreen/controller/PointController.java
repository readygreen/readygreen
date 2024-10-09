package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.PointRequestDTO;
import com.ddubucks.readygreen.model.Point;
import com.ddubucks.readygreen.model.Step;
import com.ddubucks.readygreen.repository.StepRepository;
import com.ddubucks.readygreen.service.MemberService;
import com.ddubucks.readygreen.service.PointService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/point")
public class PointController {
    private final MemberService memberService;
    private final PointService pointService;
    private final StepRepository stepRepository;

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
    public ResponseEntity<Map<LocalDate, List<Point>>> getPoints(@AuthenticationPrincipal UserDetails userDetails) {
        Map<LocalDate, List<Point>> points = pointService.getPointsByMember(userDetails.getUsername());
        return ResponseEntity.ok(points);
    }
    @GetMapping("/steps")
    public ResponseEntity<List<Step>> getSteps(@AuthenticationPrincipal UserDetails userDetails){
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(7);
        List<Step> steps = stepRepository.findByMemberEmailAndDateBetween(userDetails.getUsername(), startDate, endDate);
        return ResponseEntity.ok(steps != null ? steps : new ArrayList<>());
    }
}
