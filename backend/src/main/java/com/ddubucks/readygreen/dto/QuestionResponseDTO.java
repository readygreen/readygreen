package com.ddubucks.readygreen.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionResponseDTO {
    private String title;
    private String content;
    private LocalDateTime create_date;
    private boolean answered;
    private String reply;
}
