package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Place;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface PlaceRepository extends MongoRepository<Place, String> {
    // 카테고리별로 장소를 조회하는 메소드 추가
    List<Place> findByCategory(String category);
}