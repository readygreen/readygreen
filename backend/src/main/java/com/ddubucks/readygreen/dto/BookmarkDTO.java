package com.ddubucks.readygreen.dto;

import lombok.*;

import java.time.LocalTime;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class BookmarkDTO {
    private int id;
    private String name;
    private String destinationName;
    private double latitude;
    private double longitude;
    private LocalTime alertTime;
    private String placeId;
    private boolean isAlarm;
}
