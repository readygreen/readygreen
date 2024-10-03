package com.ddubucks.readygreen.dto;

import lombok.*;

import java.time.LocalTime;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class BlinkerDTO {
    private int id;
    private LocalTime lastAccessTime;
    private int greenDuration;
    private int redDuration;
    private String currentState; // 현재 상태 (RED, GREEN)
    private int remainingTime; // 상태 변환 남은 시간
    private double latitude;
    private double longitude;
}
