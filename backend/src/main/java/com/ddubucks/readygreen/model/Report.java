package com.ddubucks.readygreen.model;

import jakarta.persistence.*;
import lombok.*;
import com.ddubucks.readygreen.model.member.Member;

@Entity
@Table(name = "report")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Report {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    private String content;

    private boolean approved;
}
