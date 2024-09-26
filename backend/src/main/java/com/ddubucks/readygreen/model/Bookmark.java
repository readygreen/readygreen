package com.ddubucks.readygreen.model;

import com.ddubucks.readygreen.model.member.Member;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.locationtech.jts.geom.Point;

@Entity
@Table(name = "destination_bookmark")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Bookmark extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String destinationName;

    @Column(nullable = false, columnDefinition = "POINT SRID 4326")
    private Point destinationCoordinate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member member;
}
