package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.*;
import com.ddubucks.readygreen.model.feedback.*;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.repository.FeedbackRepository;
import com.ddubucks.readygreen.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final MemberRepository memberRepository;

    // 건의사항 등록
    public FeedbackResponseDTO createFeedback(FeedbackRequestDTO requestDTO, String userEmail) {
        Member member = memberRepository.findMemberByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Feedback feedback = Feedback.builder()
                .title(requestDTO.getTitle())
                .content(requestDTO.getContent())
                .type(requestDTO.getType())
                .status(FeedbackStatus.NEW)
                .createDate(LocalDateTime.now())
                .member(member)
                .build();

        feedbackRepository.save(feedback);
        return mapToResponseDTO(feedback);
    }

    // 사용자가 자신의 건의사항들 조회
    public List<FeedbackResponseDTO> getUserFeedbacks(String userEmail) {
        Member member = memberRepository.findMemberByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return feedbackRepository.findByMember(member).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    // 관리자가 모든 건의사항 조회
    public List<FeedbackResponseDTO> getAllFeedbacks() {
        return feedbackRepository.findAll().stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    // 관리자가 특정 타입의 건의사항만 조회
    public List<FeedbackResponseDTO> getFeedbacksByType(FeedbackType type) {
        return feedbackRepository.findByType(type).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    // 관리자: report 승인/반려 처리
    public FeedbackResponseDTO approveFeedback(int feedbackId, boolean isApproved) {
        Feedback feedback = feedbackRepository.findById(feedbackId)
                .orElseThrow(() -> new RuntimeException("Feedback not found"));

        if (!feedback.requiresApproval()) {
            throw new RuntimeException("Only reports require approval");
        }

        feedback.setStatus(isApproved ? FeedbackStatus.APPROVED : FeedbackStatus.REJECTED);
        feedbackRepository.save(feedback);
        return mapToResponseDTO(feedback);
    }

    // 관리자: 건의사항에 답장
    public FeedbackResponseDTO replyToFeedback(int feedbackId, FeedbackReplyDTO replyDTO) {
        Feedback feedback = feedbackRepository.findById(feedbackId)
                .orElseThrow(() -> new RuntimeException("Feedback not found"));

        if (!feedback.canReply()) {
            throw new RuntimeException("Cannot reply to this feedback");
        }

        feedback.setReply(replyDTO.getReply());
        feedbackRepository.save(feedback);
        return mapToResponseDTO(feedback);
    }

    private FeedbackResponseDTO mapToResponseDTO(Feedback feedback) {
        FeedbackResponseDTO responseDTO = new FeedbackResponseDTO();
        responseDTO.setId(feedback.getId());
        responseDTO.setTitle(feedback.getTitle());
        responseDTO.setContent(feedback.getContent());
        responseDTO.setType(feedback.getType());
        responseDTO.setStatus(feedback.getStatus());
        responseDTO.setCreateDate(feedback.getCreateDate());
        responseDTO.setReply(feedback.getReply());
        return responseDTO;
    }
}
