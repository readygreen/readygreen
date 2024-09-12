package com.ddubucks.readygreen.dto;

import lombok.Data;

@Data
public class ReportDTO {
    private Long memberId;
    private String content;
    private boolean approved;
}
