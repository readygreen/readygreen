package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.PlaceDTO;
import com.ddubucks.readygreen.model.Place;
import com.ddubucks.readygreen.repository.PlaceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PlaceService {

    private final PlaceRepository placeRepository;

    @Autowired
    public PlaceService(PlaceRepository placeRepository) {
        this.placeRepository = placeRepository;
    }

    public List<PlaceDTO> getAllPlacesSortedByProximity(double userLatitude, double userLongitude) {
        List<Place> places = placeRepository.findAll();

        return places.stream()
                .filter(place -> place.getLatitude() != 0 && place.getLongitude() != 0) // 위도, 경도가 있는 데이터만 필터링
                .sorted(Comparator.comparingDouble(place ->
                        calculateDistance(userLatitude, userLongitude, place.getLatitude(), place.getLongitude())))
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public List<PlaceDTO> getPlacesByTypeAndProximity(String type, double userLatitude, double userLongitude) {
        // type으로 필터링된 장소들 가져오기
        List<Place> places = placeRepository.findAllByType(type);

        return places.stream()
                .filter(place -> place.getLatitude() != 0 && place.getLongitude() != 0)
                .sorted(Comparator.comparingDouble(place ->
                        calculateDistance(userLatitude, userLongitude, place.getLatitude(), place.getLongitude())))
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // 지구의 반경 (km)
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c; // 거리 (km)
    }

    public PlaceDTO convertToDto(Place place) {
        return PlaceDTO.builder()
                .id(place.getId())
                .name(place.getName())
                .category(place.getCategory())
                .address(place.getAddress())
                .type(place.getType())
                .latitude(place.getLatitude())
                .longitude(place.getLongitude())
                .build();
    }
}
