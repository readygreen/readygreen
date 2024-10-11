package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Blinker;
import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface BlinkerRepository extends JpaRepository<Blinker, Integer> {

    //  신호등 하나의 기준으로 거리가 가장 가까운 신호등 조회
    @Query("SELECT b FROM Blinker b " +
            "ORDER BY ST_Distance_Sphere(b.coordinate,POINT(:longitude,:latitude) ) ASC " +
            "LIMIT 1")
    Blinker findBlinkerNearByCoordinate(double longitude, double latitude);
}
