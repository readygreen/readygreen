package com.ddubucks.readygreen.dto;

import lombok.*;

import java.util.List;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class BlinkerResponseDTO {
    List<BlinkerDTO> blinkerDTOs;
}
