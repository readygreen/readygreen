package com.ddubucks.readygreen.model;

import jakarta.persistence.Entity;
import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Getter
@Setter
@Document(collection = "place")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Place {

    @Id  // MongoDB의 ObjectId에 해당
    private String id;

    private String name;
    private String category;
    private String address;
    private String phone;
    private double latitude;
    private double longitude;
    private String photo;
}
