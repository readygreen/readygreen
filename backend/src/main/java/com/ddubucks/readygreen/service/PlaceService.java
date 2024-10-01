package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.model.Place;
import com.ddubucks.readygreen.repository.PlaceRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class PlaceService {

    private final PlaceRepository placeRepository;

    public PlaceService(PlaceRepository placeRepository) {
        this.placeRepository = placeRepository;
    }

    // 카테고리에 따른 장소 리스트 가져오기
    public List<Place> getPlacesByCategory(String category) {
        return placeRepository.findByCategory(category);
    }

    // 모든 장소 가져오기
    public List<Place> getAllPlaces() {
        return placeRepository.findAll();
    }
}
