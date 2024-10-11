package com.ddubucks.readygreen.model.bookmark;

import com.ddubucks.readygreen.model.BaseEntity;
import com.ddubucks.readygreen.model.member.Member;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.checkerframework.common.aliasing.qual.Unique;
import org.locationtech.jts.geom.Point;

import java.time.LocalTime;

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

    private LocalTime alertTime;

    @Column(unique = true)
    private String placeId;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private BookmarkType type;
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member member;
}
