package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.MapResponseDTO;
import com.ddubucks.readygreen.dto.RouteRequestDTO;
import com.ddubucks.readygreen.service.MapService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/map")
public class MapController {

    private final MapService mapService;

    @PostMapping("start")
    public ResponseEntity<?> destinationGuide(@Valid @RequestBody RouteRequestDTO routeRequestDTO) {
        MapResponseDTO mapResponseDTO = mapService.destinationGuide(routeRequestDTO);
        return ResponseEntity.ok(mapResponseDTO);
    }
}
