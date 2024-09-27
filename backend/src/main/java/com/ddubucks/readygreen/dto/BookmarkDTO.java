package com.ddubucks.readygreen.dto;

import lombok.*;

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
}
