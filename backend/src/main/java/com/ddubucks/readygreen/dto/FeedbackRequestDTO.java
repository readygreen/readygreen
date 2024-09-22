package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.feedback.FeedbackType;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FeedbackRequestDTO {
    private String title;  // 제목
    private String content; // 건의사항 내용
    private FeedbackType type; // 건의사항의 종류 (UPDATE, REQUEST, REPORT)
}
