package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Steps;
import com.ddubucks.readygreen.model.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;

public interface StepsRepository extends JpaRepository<Steps, Integer> {
    Steps findByMemberAndDate(Member member, LocalDate date);
}
