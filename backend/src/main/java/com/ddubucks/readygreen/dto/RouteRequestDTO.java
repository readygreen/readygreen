package com.ddubucks.readygreen.dto;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class RouteRequestDTO {

    @NotNull(message = "startX cannot null")
    private Double startX; //출발지 X좌표

    @NotNull(message = "startY cannot null")
    private Double startY; //출발지 Y좌표

    @JsonIgnore
    private Integer speed = 45; //진행속도(Km/h)

    @NotNull(message = "endX cannot null")
    private Double endX; //목적지 X좌표

    @NotNull(message = "endY cannot null")
    private Double endY; //목적지 Y좌표

    @NotBlank(message = "startName cannot be empty")
    private String startName; //출발지 명칭

    @NotBlank(message = "endName cannot be empty")
    private String endName; //목적지 명칭

    /*
        경로 탐색 옵션
        - 0: 추천 (기본값)
        - 4: 추천+대로우선
        - 10: 최단
        - 30: 최단거리+계단제외
    */
    @JsonIgnore
    private Integer searchOption = 0;
}
