package com.ddubucks.readygreen.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class WeatherResponse {
    private String time;
    private float temperature;
    private int sky;
    private int rainy;


}
