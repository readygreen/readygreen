package com.ddubucks.readygreen.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.locationtech.jts.geom.Point;

import java.time.LocalTime;

@Entity
@Table(name = "blinker")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Blinker extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private LocalTime startTime;

    @Column(nullable = false)
    private int greenDuration;

    @Column(nullable = false)
    private int redDuration;

    @Column(nullable = false)
    private Point coordinate;
}
