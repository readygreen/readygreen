package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Place;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PlaceRepository extends JpaRepository<Place, Integer> {
    List<Place> findAllByType(String type);
}
