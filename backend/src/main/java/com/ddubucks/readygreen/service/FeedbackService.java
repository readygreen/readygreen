package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.FeedbackDTO;
import com.ddubucks.readygreen.model.Blinker;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.feedback.Feedback;
import com.ddubucks.readygreen.model.feedback.FeedbackStatus;
import com.ddubucks.readygreen.model.feedback.FeedbackType;
import com.ddubucks.readygreen.repository.BlinkerRepository;
import com.ddubucks.readygreen.repository.FeedbackRepository;
import com.ddubucks.readygreen.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final MemberRepository memberRepository;
    private final BlinkerRepository blinkerRepository;

    // 건의사항 제출
    public FeedbackDTO submitFeedback(String email, Integer blinkerId, String feedbackType) {
        // memberId로 사용자(Member) 조회
        Member member = memberRepository.findMemberByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Invalid member ID"));

        // blinkerId로 Blinker 객체 조회
//        Blinker blinker = blinkerRepository.findById(blinkerId)
//                .orElseThrow(() -> new IllegalArgumentException("Invalid blinker ID"));

        // FeedbackType이 "UPDATE" 또는 "REQUEST" 중 하나인지 확인
        FeedbackType type = FeedbackType.valueOf(feedbackType.toUpperCase());

        // Feedback 객체 생성
        Feedback feedback = Feedback.builder()
                .member(member)
//                .blinker(blinker)
                .feedbackType(type)
                .status(FeedbackStatus.PENDING) // 기본 상태는 PENDING
                .build();

        feedbackRepository.save(feedback);
        return mapToFeedbackDTO(feedback);
    }

    // 모든 건의사항 조회 (관리자)
    public List<FeedbackDTO> getAllFeedbacks() {
        return feedbackRepository.findAll().stream()
                .map(this::mapToFeedbackDTO)
                .collect(Collectors.toList());
    }

    // 특정 사용자의 건의사항 조회
    public List<FeedbackDTO> getFeedbacksByMember(Integer memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid member ID"));

        return feedbackRepository.findByMember(member).stream()
                .map(this::mapToFeedbackDTO)
                .collect(Collectors.toList());
    }


    // 사용자가 제출한 건의사항 조회 (처리 상태별 조회 추가)
    public List<FeedbackDTO> getFeedbacksByMemberAndStatus(Integer memberId, FeedbackStatus status) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid member ID"));

        return feedbackRepository.findByMemberAndStatus(member, status).stream()
                .map(this::mapToFeedbackDTO)
                .collect(Collectors.toList());
    }

    // 관리자가 상태에 따라 건의사항 조회
    public List<FeedbackDTO> getFeedbacksByStatus(FeedbackStatus status) {
        return feedbackRepository.findByStatus(status).stream()
                .map(this::mapToFeedbackDTO)
                .collect(Collectors.toList());
    }

    // 특정 건의사항 승인 (관리자)
    public FeedbackDTO approveFeedback(Long feedbackId) {
        Feedback feedback = feedbackRepository.findById(feedbackId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid feedback ID"));

        feedback.setStatus(FeedbackStatus.APPROVED);  // 상태를 APPROVED로 변경
        feedbackRepository.save(feedback);

        return mapToFeedbackDTO(feedback);
    }

    // Helper method to convert Feedback entity to DTO
    private FeedbackDTO mapToFeedbackDTO(Feedback feedback) {
        FeedbackDTO feedbackDTO = new FeedbackDTO();
        feedbackDTO.setId(feedback.getId());
        feedbackDTO.setBlinkerId(feedback.getBlinker().getId());
        feedbackDTO.setFeedbackType(feedback.getFeedbackType().name());
        feedbackDTO.setStatus(feedback.getStatus().name());
        feedbackDTO.setCreatedAt(feedback.getCreateDate());
        return feedbackDTO;
    }
}
