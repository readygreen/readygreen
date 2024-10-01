package com.ddubucks.readygreen.model;

import jakarta.persistence.*;
import lombok.*;
import com.ddubucks.readygreen.model.member.Member;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "steps")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Steps {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private int steps;

}
