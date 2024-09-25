package com.ddubucks.readygreen.model.feedback;

import jakarta.persistence.*;
import lombok.*;
import com.ddubucks.readygreen.model.member.Member;
import java.time.LocalDateTime;

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
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;  // 작성자 ID

    @Column(nullable = false, length = 150)
    private String title;  // 제목

    @Column(nullable = false, length = 225)
    private String content;  // 내용

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private FeedbackType type;  // 분류 (info, update, add)

    @Column(name = "create_date", nullable = false)
    private LocalDateTime createDate;  // 생성일자

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private FeedbackStatus status;  // 상태 (신규, 승인, 반려)

    private String reply;

    // Report일 경우에만 승인 또는 반려 처리가 필요함
    public boolean requiresApproval() {
        return this.type == FeedbackType.REPORT;
    }

    // Report 승인/반려 여부에 따른 처리 가능 여부 확인
    public boolean canReply() {
        if (this.type == FeedbackType.REPORT) {
            return this.status == FeedbackStatus.APPROVED;
        }
        return true;
    }
}
