package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.FeedbackResponseDTO;
import com.ddubucks.readygreen.dto.FeedbackReplyDTO;
import com.ddubucks.readygreen.model.feedback.FeedbackType;
import com.ddubucks.readygreen.service.FeedbackService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/feedback")
@RequiredArgsConstructor
public class AdminFeedbackController {

    private final FeedbackService feedbackService;

    // 모든 건의사항 조회 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/all")
    public List<FeedbackResponseDTO> getAllFeedbacks() {
        return feedbackService.getAllFeedbacks();
    }

    // 특정 타입의 건의사항 조회 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/type/{type}")
    public List<FeedbackResponseDTO> getFeedbacksByType(@PathVariable String type) {
        return feedbackService.getFeedbacksByType(FeedbackType.valueOf(type.toUpperCase()));
    }

    // report 승인/반려 처리 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{id}/approve")
    public FeedbackResponseDTO approveFeedback(@PathVariable int id, @RequestParam boolean isApproved) {
        return feedbackService.approveFeedback(id, isApproved);
    }

    // 관리자 답장 기능 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{id}/reply")
    public FeedbackResponseDTO replyToFeedback(@PathVariable int id, @RequestBody FeedbackReplyDTO replyDTO) {
        return feedbackService.replyToFeedback(id, replyDTO);
    }
}
