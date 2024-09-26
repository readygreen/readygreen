package com.ddubucks.readygreen.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class LocationRequestDTO {

    @NotNull(message = "latitude cannot null")
    private double latitude;

    @NotNull(message = "longitude cannot null")
    private double longitude;

    @NotNull(message = "radius cannot null")
    private int radius;
}
