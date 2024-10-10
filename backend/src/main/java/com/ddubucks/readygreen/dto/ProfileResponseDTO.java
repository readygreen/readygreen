package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.member.Member;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfileResponseDTO {
    private Member member;
    private String badgeType;
}
