package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.FeedbackDTO;
import com.ddubucks.readygreen.model.feedback.FeedbackStatus;
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
    @GetMapping
    public List<FeedbackDTO> getAllFeedbacks() {
        return feedbackService.getAllFeedbacks();
    }

    // 특정 건의사항 승인 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{feedbackId}/approve")
    public FeedbackDTO approveFeedback(@PathVariable Long feedbackId) {
        return feedbackService.approveFeedback(feedbackId);
    }

    // 관리자가 처리 상태에 따라 건의사항 조회
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/status")
    public List<FeedbackDTO> getFeedbacksByStatus(@RequestParam FeedbackStatus status) {
        return feedbackService.getFeedbacksByStatus(status);
    }
}
