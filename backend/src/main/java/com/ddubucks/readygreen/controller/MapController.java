package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.BlinkerResponseDTO;
import com.ddubucks.readygreen.dto.LocationRequestDTO;
import com.ddubucks.readygreen.dto.MapResponseDTO;
import com.ddubucks.readygreen.dto.RouteRequestDTO;
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
    public ResponseEntity<?> destinationGuide(@Valid @RequestBody RouteRequestDTO routeRequestDTO, @AuthenticationPrincipal UserDetails userDetails) {
        MapResponseDTO mapResponseDTO = mapService.destinationGuide(routeRequestDTO, userDetails.getUsername());
        return ResponseEntity.ok(mapResponseDTO);
    }

    @GetMapping
    public ResponseEntity<?> nearbyBlinker(@Valid @RequestBody LocationRequestDTO locationRequestDTO) {
        BlinkerResponseDTO blinkerResponseDTO = mapService.nearbyBlinker(locationRequestDTO);
        return ResponseEntity.ok(blinkerResponseDTO);
    }
}
