package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Point;
import com.ddubucks.readygreen.model.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PointRepository extends JpaRepository<Point, Integer> {
    List<Point> findPointsByMember(Member member);
}
