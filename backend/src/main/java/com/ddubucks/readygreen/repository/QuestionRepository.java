package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Question;
import com.ddubucks.readygreen.model.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findByMember(Member member);
    List<Question> findByAnswered(boolean answered);
    List<Question> findByMemberAndAnswered(Member member, boolean answered);
}