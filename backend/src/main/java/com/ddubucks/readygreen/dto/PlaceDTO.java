package com.ddubucks.readygreen.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlaceDTO {
    private int id;
    private String name;
    private String category;
    private String address;
    private String type;
    private double latitude;
    private double longitude;
}
