package com.ddubucks.readygreen.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class ReportBlinkerRequestDTO {
    private int id;
    @JsonFormat(pattern = "HH:mm:ss")
    private LocalTime startTime;
    @JsonFormat(pattern = "HH:mm:ss")
    private LocalTime middleTime;
    @JsonFormat(pattern = "HH:mm:ss")
    private LocalTime endTime;
}
