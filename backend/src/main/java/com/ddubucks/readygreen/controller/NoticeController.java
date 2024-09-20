package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.NoticeResponseDTO;
import com.ddubucks.readygreen.service.NoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/notice")
@RequiredArgsConstructor
public class NoticeController {

    private final NoticeService noticeService;

    // 모든 공지사항 조회 (중요한 공지사항이 먼저 표시됨)
    @GetMapping
    public List<NoticeResponseDTO> getAllNotices() {
        return noticeService.getAllNotices();
    }

    // 공지사항 상세 조회
    @GetMapping("/{id}")
    public NoticeResponseDTO getNoticeById(@PathVariable int id) {
        return noticeService.getNoticeById(id);
    }
}
