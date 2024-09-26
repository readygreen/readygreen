package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.*;
import com.ddubucks.readygreen.service.MapService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
    public ResponseEntity<?> getNearbyBlinker(@RequestParam(required = false) double latitude,
                                              @RequestParam(required = false) double longitude,
                                              @RequestParam(required = false) int radius) {
        BlinkerResponseDTO blinkerResponseDTO = mapService.getNearbyBlinker(latitude, longitude, radius);
        return ResponseEntity.ok(blinkerResponseDTO);
    }

    @GetMapping("blinker")
    public ResponseEntity<?> getBlinker(@RequestParam(required = false) List<Integer> blinkerIDs) {
        BlinkerResponseDTO blinkerResponseDTO = mapService.getBlinker(blinkerIDs);
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

    @DeleteMapping("bookmark")
    public ResponseEntity<?> deleteBookmark(@RequestParam(required = false) List<Integer> bookmarkIDs, @AuthenticationPrincipal UserDetails userDetails) {
        mapService.deleteBookmark(bookmarkIDs, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }
}
