package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.FeedbackRequestDTO;
import com.ddubucks.readygreen.dto.FeedbackResponseDTO;
import com.ddubucks.readygreen.service.FeedbackService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/feedback")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    // 사용자가 건의사항 작성
    @PostMapping
    public FeedbackResponseDTO createFeedback(@RequestBody FeedbackRequestDTO requestDTO, @RequestParam String userEmail) {
        return feedbackService.createFeedback(requestDTO, userEmail);
    }

    // 사용자가 자신의 건의사항 조회
    @GetMapping
    public List<FeedbackResponseDTO> getUserFeedbacks(@RequestParam String userEmail) {
        return feedbackService.getUserFeedbacks(userEmail);
    }
}
