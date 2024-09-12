package com.ddubucks.readygreen.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class AnnouncementDTO {
    private Long id;
    private String title;
    private String content;
    private LocalDateTime createdAt;
    private boolean isImportant;
    private String authorName;
}
