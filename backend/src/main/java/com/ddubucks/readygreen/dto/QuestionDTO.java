package com.ddubucks.readygreen.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionDTO {
    private Long id;
    private String title;
    private String content;
    private String reply;
    private boolean answered;
    private LocalDateTime createdAt;
}
