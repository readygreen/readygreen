package com.ddubucks.readygreen.model.report;

import com.ddubucks.readygreen.model.BaseEntity;
import com.ddubucks.readygreen.model.Blinker;
import com.ddubucks.readygreen.model.member.Member;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalTime;

@Entity
@Table(name = "report")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Report extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "blinker_id", nullable = false)
    private Blinker blinker;

    @Column(nullable = false)
    private LocalTime greenStartTime;

    @Column(nullable = false)
    private LocalTime redStartTime;

    @Column(nullable = false)
    private LocalTime nextGreenStartTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportStatus status = ReportStatus.PENDING;
}
