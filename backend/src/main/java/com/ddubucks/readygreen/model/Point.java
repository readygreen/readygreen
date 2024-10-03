package com.ddubucks.readygreen.model;

import jakarta.persistence.*;
import lombok.*;
import com.ddubucks.readygreen.model.member.Member;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

@Entity
@Table(name = "point")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Point {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(nullable = false, length = 100)
    private String description;

    @Column(nullable = false)
    private int point;

    @Column(name = "create_date", nullable = false)
    private LocalDateTime createDate;
}
