package com.ddubucks.readygreen.dto;

import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class RouteRecordDTO {
    private int id;
    private String startName;
    private double startLatitude;
    private double startLongitude;
    private String endName;
    private double endLatitude;
    private double endLongitude;
}