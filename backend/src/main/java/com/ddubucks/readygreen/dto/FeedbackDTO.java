package com.ddubucks.readygreen.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FeedbackDTO {

    private Long id;
    private Integer blinkerId;
    private String feedbackType;  // "UPDATE", "REQUEST"
    private String status;  // "PENDING", "APPROVED"
    private LocalDateTime createdAt;

}
