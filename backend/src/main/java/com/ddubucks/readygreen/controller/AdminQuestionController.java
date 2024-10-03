package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.QuestionDTO;
import com.ddubucks.readygreen.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/question")
@RequiredArgsConstructor
public class AdminQuestionController {

    private final QuestionService questionService;

    // 모든 질문 조회 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public List<QuestionDTO> getAllQuestions() {
        return questionService.getAllQuestions();
    }

    // 질문 답변 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{questionId}/reply")
    public QuestionDTO replyToQuestion(@PathVariable Long questionId, @RequestParam String reply) {
        return questionService.replyToQuestion(questionId, reply);
    }

    // 관리자가 답변 완료/미완료에 따라 질문 조회
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/status")
    public List<QuestionDTO> getQuestionsByStatus(@RequestParam boolean answered) {
        return questionService.getQuestionsByStatus(answered);
    }
}
