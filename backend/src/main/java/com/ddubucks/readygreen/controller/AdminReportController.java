package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.ReportDTO;
import com.ddubucks.readygreen.model.report.ReportStatus;
import com.ddubucks.readygreen.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/report")
@RequiredArgsConstructor
public class AdminReportController {

    private final ReportService reportService;

    // 모든 제보 조회 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public List<ReportDTO> getAllReports() {
        return reportService.getAllReports();
    }

    // 특정 제보 상세 조회 (관리자만 가능)
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/{reportId}")
    public ReportDTO getReportById(@PathVariable Long reportId) {
        return reportService.getReportById(reportId);
    }

    // 제보 상태 업데이트 (관리자가 제보를 승인 또는 반려)
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{reportId}")
    public ReportDTO updateReportStatus(@PathVariable Long reportId, @RequestParam String status) {
        return reportService.updateReportStatus(reportId, status);
    }

    // 관리자가 처리 상태에 따라 제보 조회
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/status")
    public List<ReportDTO> getReportsByStatus(@RequestParam ReportStatus status) {
        return reportService.getReportsByStatus(status);
    }
}
