package com.ddubucks.readygreen.model;

import com.ddubucks.readygreen.model.member.Member;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notice")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    private String content;

    private LocalDateTime createdAt;

    private boolean isImportant;

    @ManyToOne
    @JoinColumn(name = "author_id")
    private Member author;
}
