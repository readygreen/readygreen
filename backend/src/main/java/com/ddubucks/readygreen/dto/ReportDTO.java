package com.ddubucks.readygreen.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReportDTO {

    private Long id;
    private Integer blinkerId;
    private LocalTime greenStartTime;
    private LocalTime redStartTime;
    private LocalTime nextGreenStartTime;
    private String status;
    private LocalDateTime createdAt;
}

