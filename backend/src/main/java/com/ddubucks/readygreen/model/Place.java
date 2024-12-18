package com.ddubucks.readygreen.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "place")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Place {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String name;
    private String category;
    private String address;
    private String number;
    private String type;
    private double latitude;
    private double longitude;

}