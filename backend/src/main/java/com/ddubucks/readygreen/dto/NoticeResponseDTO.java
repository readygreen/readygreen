package com.ddubucks.readygreen.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class NoticeResponseDTO {
    private int id;
    private String title;  // 공지사항 제목
    private String content;  // 공지사항 내용
    private LocalDateTime createDate;  // 작성 날짜 및 시간
    private String author;  // 작성자 (관리자 이름)
    private boolean isImportant;  // 중요 여부
}
