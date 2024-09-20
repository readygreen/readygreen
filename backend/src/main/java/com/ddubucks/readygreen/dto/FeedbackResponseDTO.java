package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.feedback.FeedbackStatus;
import com.ddubucks.readygreen.model.feedback.FeedbackType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class FeedbackResponseDTO {
    private int id;
    private String title; // 제목
    private String content; // 건의사항 내용
    private FeedbackType type; // 건의사항 종류
    private FeedbackStatus status; // 건의사항 상태 (신규, 승인, 반려)
    private LocalDateTime createDate;  // 생성일자
    private String reply; // 관리자의 답장 (없을 수도 있음)
}
