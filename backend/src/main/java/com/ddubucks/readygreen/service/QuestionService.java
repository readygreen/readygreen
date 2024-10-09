package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.QuestionDTO;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.Question;
import com.ddubucks.readygreen.repository.MemberRepository;
import com.ddubucks.readygreen.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuestionService {

    private final QuestionRepository questionRepository;
    private final MemberRepository memberRepository;

    // 질문 제출
    public QuestionDTO submitQuestion(String email, String title, String content) {
        Member member = memberRepository.findMemberByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Invalid member ID"));

        Question question = Question.builder()
                .member(member)
                .title(title)
                .content(content)
                .answered(false)  // 질문은 처음에 답변되지 않은 상태
                .build();

        questionRepository.save(question);
        return mapToQuestionDTO(question);
    }

    // 특정 사용자의 질문 조회 (처리 상태별 조회 추가)
    public List<QuestionDTO> getQuestionsByMemberAndStatus(String email, boolean answered) {
        Member member = memberRepository.findMemberByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Invalid member ID"));

        return questionRepository.findByMemberAndAnswered(member, answered).stream()
                .map(this::mapToQuestionDTO)
                .collect(Collectors.toList());
    }

    // 관리자가 답변 완료/미완료에 따라 질문 조회
    public List<QuestionDTO> getQuestionsByStatus(boolean answered) {
        return questionRepository.findByAnswered(answered).stream()
                .map(this::mapToQuestionDTO)
                .collect(Collectors.toList());
    }

    // 모든 질문 조회 (관리자)
    public List<QuestionDTO> getAllQuestions() {
        return questionRepository.findAll().stream()
                .map(this::mapToQuestionDTO)
                .collect(Collectors.toList());
    }

    // 특정 사용자의 질문 조회
    public List<Question> getQuestionsByMember(String email) {
        Member member = memberRepository.findMemberByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Invalid member ID"));

        return questionRepository.findByMember(member);
    }

    // 특정 질문에 답변 (관리자)
    public QuestionDTO replyToQuestion(Long questionId, String reply) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid question ID"));

        question.setReply(reply);
        question.setAnswered(true);
        questionRepository.save(question);

        return mapToQuestionDTO(question);
    }

    // Helper method to convert Question entity to DTO
    private QuestionDTO mapToQuestionDTO(Question question) {
        QuestionDTO questionDTO = new QuestionDTO();
        questionDTO.setTitle(question.getTitle());
        questionDTO.setContent(question.getContent());
        return questionDTO;
    }
}
