package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.QuestionDTO;
import com.ddubucks.readygreen.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/question")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    // 질문 제출 (사용자)
    @PostMapping
    public QuestionDTO submitQuestion(@RequestParam Integer memberId, @RequestBody QuestionDTO questionDTO) {
        return questionService.submitQuestion(memberId, questionDTO.getTitle(), questionDTO.getContent());
    }

    // 특정 사용자의 질문 조회 (사용자)
    @GetMapping("/user/{memberId}")
    public List<QuestionDTO> getQuestionsByMember(@PathVariable Integer memberId) {
        return questionService.getQuestionsByMember(memberId);
    }

    // 사용자가 답변 완료/미완료에 따라 자신의 질문 조회
    @GetMapping("/user/{memberId}/status")
    public List<QuestionDTO> getQuestionsByMemberAndStatus(@PathVariable Integer memberId, @RequestParam boolean answered) {
        return questionService.getQuestionsByMemberAndStatus(memberId, answered);
    }
}
