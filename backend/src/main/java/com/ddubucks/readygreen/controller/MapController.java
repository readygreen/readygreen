package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.*;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.service.FcmService;
import com.ddubucks.readygreen.service.MapService;
import com.ddubucks.readygreen.service.MemberService;
import com.ddubucks.readygreen.service.RedisService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.FirebaseMessagingException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.Response;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping("start")
    public ResponseEntity<MapResponseDTO> getDestinationGuide(@Valid @RequestBody RouteRequestDTO routeRequestDTO, @AuthenticationPrincipal UserDetails userDetails) throws FirebaseMessagingException {
        MapResponseDTO mapResponseDTO = mapService.getDestinationGuide(routeRequestDTO, userDetails.getUsername());
        mapResponseDTO.setOrigin(routeRequestDTO.getStartName());
        mapResponseDTO.setDestination(routeRequestDTO.getEndName());
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
    public ResponseEntity<String> deleteGuide(@AuthenticationPrincipal UserDetails userDetails, @RequestParam(name = "isWatch") boolean isWatch) throws FirebaseMessagingException {
        redisService.delete("dir|"+userDetails.getUsername());
        Member member = memberService.getMemberInfo(userDetails.getUsername());
        if(member.getWatch()!=null)
            fcmService.sendMessageToOtherDevice(member,isWatch,2);
        return ResponseEntity.ok().build();
    }

    @PostMapping("guide")
    public ResponseEntity<String> doneGuide(@AuthenticationPrincipal UserDetails userDetails, @RequestParam(name = "isWatch") boolean isWatch) throws FirebaseMessagingException {
        redisService.delete("dir|"+userDetails.getUsername());
        Member member = memberService.getMemberInfo(userDetails.getUsername());
        if(member.getWatch()!=null)
            fcmService.sendMessageToOtherDevice(member,isWatch,2);
        return ResponseEntity.ok().build();
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
