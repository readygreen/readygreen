package com.ddubucks.readygreen.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class LocationRequestDTO {
    private double latitude;
    private double longitude;
    private int radius;
}
