package com.ddubucks.readygreen.dto;

import lombok.Data;

@Data
public class InquiryDTO {
    private Long memberId;
    private String question;
    private String answer;
    private boolean answered;
}
