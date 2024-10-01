package com.ddubucks.readygreen.dto;

import lombok.*;

import java.time.LocalDateTime;
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
    private Double endlat;
    private Double endlng;
    private Double distance;
    private LocalDateTime time;
}
