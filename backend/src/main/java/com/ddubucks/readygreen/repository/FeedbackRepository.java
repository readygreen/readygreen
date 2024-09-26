package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.feedback.Feedback;
import com.ddubucks.readygreen.model.feedback.FeedbackStatus;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.feedback.FeedbackType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FeedbackRepository extends JpaRepository<Feedback, Long> {
    List<Feedback> findByMember(Member member);
    List<Feedback> findByFeedbackType(FeedbackType feedbackType);
    List<Feedback> findByStatus(FeedbackStatus status);
    List<Feedback> findByMemberAndStatus(Member member, FeedbackStatus status);
}

