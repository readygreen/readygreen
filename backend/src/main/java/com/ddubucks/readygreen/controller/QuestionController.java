package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.QuestionDTO;
import com.ddubucks.readygreen.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import com.ddubucks.readygreen.model.Question;

import java.util.List;

@RestController
@RequestMapping("/question")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    // 질문 제출 (사용자)
    @PostMapping
    public QuestionDTO submitQuestion(@AuthenticationPrincipal UserDetails userDetails, @RequestBody QuestionDTO questionDTO) {
        return questionService.submitQuestion(userDetails.getUsername(), questionDTO.getTitle(), questionDTO.getContent());
    }

    // 특정 사용자의 질문 조회 (사용자)
    @GetMapping
    public List<Question> getQuestionsByMember(@AuthenticationPrincipal UserDetails userDetails) {
        return questionService.getQuestionsByMember(userDetails.getUsername());
    }

    // 사용자가 답변 완료/미완료에 따라 자신의 질문 조회
    @GetMapping("/user/status")
    public List<QuestionDTO> getQuestionsByMemberAndStatus(@AuthenticationPrincipal UserDetails userDetails, @RequestParam boolean answered) {
        return questionService.getQuestionsByMemberAndStatus(userDetails.getUsername(), answered);
    }
}
