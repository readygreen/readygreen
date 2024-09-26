package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.*;
import com.ddubucks.readygreen.service.MapService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/map")
public class MapController {

    private final MapService mapService;

    @PostMapping("start")
    public ResponseEntity<?> getDestinationGuide(@Valid @RequestBody RouteRequestDTO routeRequestDTO, @AuthenticationPrincipal UserDetails userDetails) {
        MapResponseDTO mapResponseDTO = mapService.getDestinationGuide(routeRequestDTO, userDetails.getUsername());
        return ResponseEntity.ok(mapResponseDTO);
    }

    @GetMapping
    public ResponseEntity<?> getNearbyBlinker(@Valid @RequestBody LocationRequestDTO locationRequestDTO) {
        BlinkerResponseDTO blinkerResponseDTO = mapService.getNearbyBlinker(locationRequestDTO);
        return ResponseEntity.ok(blinkerResponseDTO);
    }

    @GetMapping("blinker")
    public ResponseEntity<?> getBlinker(@Valid @RequestBody BlinkerRequestDTO blinkerRequestDTO) {
        BlinkerResponseDTO blinkerResponseDTO = mapService.getBlinker(blinkerRequestDTO);
        return ResponseEntity.ok(blinkerResponseDTO);
    }

    @GetMapping("bookmark")
    public ResponseEntity<?> getBookmark(@AuthenticationPrincipal UserDetails userDetails) {
        BookmarkResponseDTO bookmarkResponseDTO = mapService.getBookmark(userDetails.getUsername());
        return ResponseEntity.ok(bookmarkResponseDTO);
    }

    @PostMapping("bookmark")
    public ResponseEntity<?> saveBookmark(@Valid @RequestBody BookmarkRequestDTO bookmarkRequestDTO, @AuthenticationPrincipal UserDetails userDetails) {
        mapService.saveBookmark(bookmarkRequestDTO, userDetails.getUsername());
        return ResponseEntity.ok().build();
    }
}
