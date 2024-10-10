package com.ddubucks.readygreen.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;
import org.locationtech.jts.geom.Point;

import java.time.LocalTime;

@Entity
@Table(name = "blinker")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Blinker extends BaseEntity {
    @Id
    private int id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private LocalTime startTime;

    @Column(nullable = false)
    private int greenDuration;

    @Column(nullable = false)
    private int redDuration;

    @Column(nullable = false, columnDefinition = "POINT SRID 4326")
    private Point coordinate;
}
