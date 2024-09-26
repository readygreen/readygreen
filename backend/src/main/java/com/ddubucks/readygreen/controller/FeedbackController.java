package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.FeedbackDTO;
import com.ddubucks.readygreen.model.feedback.FeedbackStatus;
import com.ddubucks.readygreen.service.FeedbackService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/feedback")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    // 건의사항 제출 (사용자)
    @PostMapping
    public FeedbackDTO submitFeedback(@RequestParam Integer memberId, @RequestParam Integer blinkerId,
                                      @RequestParam String feedbackType) {
        return feedbackService.submitFeedback(memberId, blinkerId, feedbackType);
    }

    // 특정 사용자의 건의사항 조회 (사용자)
    @GetMapping("/user/{memberId}")
    public List<FeedbackDTO> getFeedbacksByMember(@PathVariable Integer memberId) {
        return feedbackService.getFeedbacksByMember(memberId);
    }

    // 사용자가 처리 상태에 따라 자신의 건의사항 조회
    @GetMapping("/user/{memberId}/status")
    public List<FeedbackDTO> getFeedbacksByMemberAndStatus(@PathVariable Integer memberId, @RequestParam FeedbackStatus status) {
        return feedbackService.getFeedbacksByMemberAndStatus(memberId, status);
    }
}
