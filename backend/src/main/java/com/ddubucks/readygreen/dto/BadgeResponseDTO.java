package com.ddubucks.readygreen.dto;

import ch.qos.logback.classic.spi.LoggingEventVO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Builder
public class BadgeResponseDTO {
    private String type;
    private int title;

}
