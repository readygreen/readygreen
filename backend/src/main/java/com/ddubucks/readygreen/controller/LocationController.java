package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.service.PySparkService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/location")
@RequiredArgsConstructor
public class LocationController {

    private final PySparkService pySparkService;

    // 사용자가 보낸 위도와 경도를 받아 PySpark 스크립트를 실행하고, 결과를 반환
    @GetMapping
    public ResponseEntity<List<String>> getLocations(@RequestParam double latitude, @RequestParam double longitude) {
        List<String> sortedLocations = pySparkService.calculateDistances(latitude, longitude);
        return ResponseEntity.ok(sortedLocations);
    }
}
