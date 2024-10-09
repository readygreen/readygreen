package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.model.Place;
import com.ddubucks.readygreen.service.PlaceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
@RestController
@RequestMapping("/place")
@RequiredArgsConstructor
public class PlaceController {

    private final PlaceService placeService;

    // 카테고리별 장소 리스트 제공
    @GetMapping
    public List<Place> getPlaces(@RequestParam String category) {
        return placeService.getPlacesByCategory(category);
    }

    // 모든 장소 가져오기
    @GetMapping("/all")
    public List<Place> getAllPlaces() {
        return placeService.getAllPlaces();
    }
}
