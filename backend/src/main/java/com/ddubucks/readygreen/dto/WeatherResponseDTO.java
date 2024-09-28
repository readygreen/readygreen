package com.ddubucks.readygreen.dto;

import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class WeatherResponseDTO {
    private String time;
    private float temperature;
    private int sky;
    private int rainy;


}
