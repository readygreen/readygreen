package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Step;
import com.ddubucks.readygreen.model.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.http.ResponseEntity;

import java.time.LocalDate;
import java.util.List;

public interface StepRepository extends JpaRepository<Step, Integer> {
    Step findByMemberAndDate(Member member, LocalDate date);
    List<Step> findByMemberEmailAndDateBetween(String email, LocalDate startDate, LocalDate endDate);
}
