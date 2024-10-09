package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Location;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface LocationRepository extends MongoRepository<Location, String> {
    List<Location> findByCategory(String category);
}
