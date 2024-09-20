package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.feedback.Feedback;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.feedback.FeedbackType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FeedbackRepository extends JpaRepository<Feedback, Integer> {
    // 특정 사용자가 작성한 건의사항들 조회
    List<Feedback> findByMember(Member member);

    // 특정 종류의 건의사항 조회 (관리자용)
    List<Feedback> findByType(FeedbackType type);
}
