package com.ddubucks.readygreen.model;

import jakarta.persistence.*;
import lombok.*;
import com.ddubucks.readygreen.model.member.Member;
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
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;  // 작성자 (관리자)

    @Column(nullable = false, length = 100)
    private String title;  // 공지사항 제목

    @Column(nullable = false, length = 225)
    private String content;  // 공지사항 내용

    @Column(name = "create_date", nullable = false)
    private LocalDateTime createDate;  // 작성 날짜 및 시간

    @Column(nullable = false)
    private boolean isImportant;  // 공지사항의 중요 여부 (중요하면 맨 위에 표시)
}
