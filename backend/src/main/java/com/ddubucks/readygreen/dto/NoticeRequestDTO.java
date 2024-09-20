package com.ddubucks.readygreen.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NoticeRequestDTO {
    private String title;  // 공지사항 제목
    private String content;  // 공지사항 내용
    private boolean isImportant;  // 공지사항의 중요 여부
}
