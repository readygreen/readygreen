package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.*;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.Step;
import com.ddubucks.readygreen.repository.MemberRepository;
import com.ddubucks.readygreen.repository.StepRepository;
import com.ddubucks.readygreen.service.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.FirebaseMessagingException;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.Response;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalDate;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/map")
public class MapController {

    private final MapService mapService;
    private final RedisService redisService;
    private final FcmService fcmService;
    private final MemberService memberService;
    private final ObjectMapper objectMapper;
    private final PointService pointService;
    private final StepRepository stepRepository;
    private final MemberRepository memberRepository;

    @PostMapping("start")
    public ResponseEntity<MapResponseDTO> getDestinationGuide(@Valid @RequestBody RouteRequestDTO routeRequestDTO, @AuthenticationPrincipal UserDetails userDetails) throws FirebaseMessagingException {
        MapResponseDTO mapResponseDTO = mapService.getDestinationGuide(routeRequestDTO, userDetails.getUsername());
        Double distance = mapService.getDistance(mapResponseDTO.getRouteDTO().getFeatures());
        mapResponseDTO.setOrigin(routeRequestDTO.getStartName());
        mapResponseDTO.setDestination(routeRequestDTO.getEndName());
        mapResponseDTO.setEndlng(routeRequestDTO.getEndX());
        mapResponseDTO.setEndlat(routeRequestDTO.getEndY());
        mapResponseDTO.setDistance(distance);
        LocalDateTime now = LocalDateTime.now();
        mapResponseDTO.setTime(now);
        redisService.save("dir|"+userDetails.getUsername(),mapResponseDTO);
        Member member = memberService.getMemberInfo(userDetails.getUsername());
        if(member.getWatch()!=null)
            fcmService.sendMessageToOtherDevice(member,routeRequestDTO.isWatch(),1);
        return ResponseEntity.ok(mapResponseDTO);
    }

    @GetMapping("guide")
    public ResponseEntity<Object> getCheckAlreadyGuide(@AuthenticationPrincipal UserDetails userDetails){
        System.out.println(userDetails.getUsername());
        // Redis에서 데이터를 가져옴
        Object redisData = redisService.find("dir|" + userDetails.getUsername());
        // 데이터가 없을 경우
        if (redisData == null) {
            return ResponseEntity.noContent().build();
        }
        System.out.println(redisData);
        return ResponseEntity.ok().body(redisData);
    }
    @DeleteMapping("guide")
    @Operation(summary = "중간에 길안내 중단")
    public ResponseEntity<String> deleteGuide(@AuthenticationPrincipal UserDetails userDetails, @RequestParam(name = "isWatch") boolean isWatch) throws FirebaseMessagingException {
        redisService.delete("dir|"+userDetails.getUsername());
        Member member = memberService.getMemberInfo(userDetails.getUsername());
        if(member.getWatch()!=null)
            fcmService.sendMessageToOtherDevice(member,isWatch,2);
        return ResponseEntity.ok().build();
    }

    @PostMapping("guide")
    @Operation(summary = "길안내 완료 끝까지 도달함")
    public ResponseEntity<String> doneGuide(@AuthenticationPrincipal UserDetails userDetails, @RequestBody ArriveRequestDTO arriveRequestDTO) throws FirebaseMessagingException {
        redisService.delete("dir|"+userDetails.getUsername());

        // 사용자 정보 가져오기
        Member member = memberService.getMemberInfo(userDetails.getUsername());
        // FCM 메시지 전송 (optional)
        if (member.getWatch() != null) {
            fcmService.sendMessageToOtherDevice(member, arriveRequestDTO.isWatch(), 2);
        }

        // 시작 시간과 현재 시간으로 경과 시간(초) 계산
        LocalDateTime startTime = arriveRequestDTO.getStartTime();
        LocalDateTime now = LocalDateTime.now();
        Duration duration = Duration.between(startTime, now);
        long seconds = duration.getSeconds();
        int steps = (int)(arriveRequestDTO.getDistance() / 0.7);
        int point = steps / 10;
        double speedMetersPerSecond = (seconds > 0) ? arriveRequestDTO.getDistance() / seconds : 0;
        double speedKmPerHour = speedMetersPerSecond * 3.6;
        PointRequestDTO pointRequestDTO = PointRequestDTO.builder()
                .point(point)
                .description("걸음수 만큼 포인트")
                .build();
        pointService.addPoint(userDetails.getUsername(),pointRequestDTO);
        System.out.println("Total distance: " + arriveRequestDTO.getDistance() + " meters");
        System.out.println("Total time: " + seconds + " seconds");
        System.out.println("Calculated speed: " + speedKmPerHour + " km/h");

        LocalDate today = LocalDate.now();
        Step existingSteps = stepRepository.findByMemberAndDate(member, today);
        if (existingSteps != null) {
            // 이미 있는 기록에 걸음수 추가
            existingSteps.setSteps(existingSteps.getSteps() + steps);
            stepRepository.save(existingSteps);
        } else {
            // 새로 걸음수 기록 추가
            Step newSteps = Step.builder()
                    .member(member)
                    .date(today)
                    .steps(steps)
                    .build();
            stepRepository.save(newSteps);
        }

        member.setSpeed(speedKmPerHour);
        memberRepository.save(member);
        return ResponseEntity.ok("길 안내 완료. 속도: " + speedKmPerHour + " km/h");
    }

    @PostMapping("guide/check")
    public ResponseEntity<String> checkGuide(@AuthenticationPrincipal UserDetails userDetails){
        if(redisService.hasKey("dir|"+userDetails.getUsername())){
            return ResponseEntity.ok("데이터 있음");
        }else {
            return ResponseEntity.noContent().build();
        }
    }

    @GetMapping
    public ResponseEntity<BlinkerResponseDTO> getNearbyBlinker(@RequestParam(required = false) double latitude,
                                              @RequestParam(required = false) double longitude,
                                              @RequestParam(required = false) int radius) {
        BlinkerResponseDTO blinkerResponseDTO = mapService.getNearbyBlinker(latitude, longitude, radius);
        return ResponseEntity.ok(blinkerResponseDTO);
    }

    @GetMapping("blinker")
    public ResponseEntity<BlinkerResponseDTO> getBlinker(@RequestParam(required = false) List<Integer> blinkerIDs) {
        BlinkerResponseDTO blinkerResponseDTO = mapService.getBlinker(blinkerIDs);
        return ResponseEntity.ok(blinkerResponseDTO);
    }

    @GetMapping("route")
    public ResponseEntity<RouteRecordResponseDTO> getRouteRecord(@AuthenticationPrincipal UserDetails userDetails) {
        RouteRecordResponseDTO routeRecordResponseDTO = mapService.getRouteRecord(userDetails.getUsername());
        return ResponseEntity.ok(routeRecordResponseDTO);
    }

    @GetMapping("bookmark")
    public ResponseEntity<BookmarkResponseDTO> getBookmark(@AuthenticationPrincipal UserDetails userDetails) {
        BookmarkResponseDTO bookmarkResponseDTO = mapService.getBookmark(userDetails.getUsername());
        return ResponseEntity.ok(bookmarkResponseDTO);
    }

    @PostMapping("bookmark")
    public ResponseEntity<?> saveBookmark(@Valid @RequestBody BookmarkRequestDTO bookmarkRequestDTO, @AuthenticationPrincipal UserDetails userDetails) {
        mapService.saveBookmark(bookmarkRequestDTO, userDetails.getUsername());
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("bookmark")
    public ResponseEntity<?> deleteBookmark(@RequestParam(required = false) List<Integer> bookmarkIDs, @AuthenticationPrincipal UserDetails userDetails) {
        mapService.deleteBookmark(bookmarkIDs, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }
}
