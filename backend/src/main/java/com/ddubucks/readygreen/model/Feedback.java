package com.ddubucks.readygreen.model;

import jakarta.persistence.*;
import lombok.*;
import com.ddubucks.readygreen.model.member.Member;

@Entity
@Table(name = "feedback")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Feedback {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    private String question;

    private String answer;

    private boolean answered;
}
