package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Integer> {

    Optional<Member> findMemberByEmail(String email);

    void deleteMemberByEmail(String email);
}
