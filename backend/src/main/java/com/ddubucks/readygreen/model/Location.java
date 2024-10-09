package com.ddubucks.readygreen.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Getter
@Setter
@Document(collection = "location")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Location {

    @Id
    private String id;

    private String name;
    private String category;
    private String address;
    private String phone;
    private double latitude;
    private double longitude;
    private double distance;
}
