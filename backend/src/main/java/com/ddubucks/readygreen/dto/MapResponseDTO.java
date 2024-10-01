package com.ddubucks.readygreen.dto;

import lombok.*;

import java.util.List;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class MapResponseDTO {
    private RouteDTO routeDTO;
    private List<BlinkerDTO> blinkerDTOs;
    private String origin;
    private String destination;
}
