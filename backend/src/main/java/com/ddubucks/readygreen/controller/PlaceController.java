package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.PlaceDTO;
import com.ddubucks.readygreen.service.PlaceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/place")
public class PlaceController {

    private final PlaceService placeService;

    @Autowired
    public PlaceController(PlaceService placeService) {
        this.placeService = placeService;
    }

    /**
     * 현재 위치를 기준으로 특정 type의 장소를 가까운 순으로 반환합니다.
     *
     * @param type - 장소의 유형
     * @param userLatitude - 사용자의 현재 위도
     * @param userLongitude - 사용자의 현재 경도
     * @return 가까운 순으로 정렬된 type별 장소 목록
     */
    @GetMapping("/nearby")
    public ResponseEntity<List<PlaceDTO>> getPlacesByTypeAndProximity(
            @RequestParam String type,
            @RequestParam double userLatitude,
            @RequestParam double userLongitude) {

        List<PlaceDTO> places = placeService.getPlacesByTypeAndProximity(type, userLatitude, userLongitude);
        return ResponseEntity.ok(places);
    }

    /**
     * 현재 위치를 기준으로 모든 장소를 가까운 순으로 반환합니다.
     *
     * @param userLatitude - 사용자의 현재 위도
     * @param userLongitude - 사용자의 현재 경도
     * @return 가까운 순으로 정렬된 장소 목록
     */
    @GetMapping("/nearby/all")
    public ResponseEntity<List<PlaceDTO>> getAllPlacesSortedByProximity(
            @RequestParam double userLatitude,
            @RequestParam double userLongitude) {

        List<PlaceDTO> places = placeService.getAllPlacesSortedByProximity(userLatitude, userLongitude);
        return ResponseEntity.ok(places);
    }
}
