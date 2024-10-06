package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.RouteRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RouteRecordRepository extends JpaRepository<RouteRecord, Integer> {
    @Query("SELECT r FROM RouteRecord r WHERE r.member.email = :email")
    List<RouteRecord> findAllByEmail(String email);

    Optional<RouteRecord> findTopByMemberEmailOrderByCreateDateDesc(String email);




}
