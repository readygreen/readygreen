package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Point;
import com.ddubucks.readygreen.model.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface PointRepository extends JpaRepository<Point, Integer> {
    List<Point> findPointsByMember(Member member);

    @Query("SELECT CASE WHEN COUNT(p) > 0 THEN true ELSE false END FROM Point p WHERE p.member.email = :username AND p.description = :description AND FUNCTION('DATE', p.createDate) = :today")
    boolean existsByMemberEmailAndDescriptionAndCreateDate(@Param("username") String username, @Param("description") String description, @Param("today") LocalDate today);

}
