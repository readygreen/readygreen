package com.ddubucks.readygreen.model;

import com.ddubucks.readygreen.model.member.Member;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.locationtech.jts.geom.Point;

@Entity
@Table(name = "route_record")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RouteRecord extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false)
    private String startName;

    @Column(nullable = false, columnDefinition = "POINT SRID 4326")
    private Point startCoordinate;

    @Column(nullable = false)
    private String endName;

    @Column(nullable = false, columnDefinition = "POINT SRID 4326")
    private Point endCoordinate;
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member member;
}
