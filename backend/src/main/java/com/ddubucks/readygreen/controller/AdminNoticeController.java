package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.NoticeRequestDTO;
import com.ddubucks.readygreen.dto.NoticeResponseDTO;
import com.ddubucks.readygreen.service.NoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/notice")
@RequiredArgsConstructor
public class AdminNoticeController {

    private final NoticeService noticeService;

    // 공지사항 작성 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    public NoticeResponseDTO createNotice(@RequestBody NoticeRequestDTO requestDTO, @RequestParam String userEmail) {
        return noticeService.createNotice(requestDTO, userEmail);
    }

    // 공지사항 수정 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}")
    public NoticeResponseDTO updateNotice(@PathVariable int id, @RequestBody NoticeRequestDTO requestDTO, @RequestParam String userEmail) {
        return noticeService.updateNotice(id, requestDTO, userEmail);
    }

    // 공지사항 삭제 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public void deleteNotice(@PathVariable int id, @RequestParam String userEmail) {
        noticeService.deleteNotice(id, userEmail);
    }
}
