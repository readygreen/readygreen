package com.ddubucks.readygreen.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@NoArgsConstructor
@AllArgsConstructor
@Getter
public class ArriveRequestDTO {
    @NotNull(message = "distance cannot be null")
    private Double distance;
    @NotNull(message = "startTime cannot be null")
    private LocalDateTime startTime;
    @NotNull(message = "watch cannot be null")
    private boolean isWatch;
}
