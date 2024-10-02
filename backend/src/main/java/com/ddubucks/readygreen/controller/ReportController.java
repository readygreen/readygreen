package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.ReportDTO;
import com.ddubucks.readygreen.model.report.ReportStatus;
import com.ddubucks.readygreen.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/report")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    // 제보 제출 (사용자가 신호등을 클릭하여 제보)
    @PostMapping
    public ReportDTO submitReport(@RequestParam Integer memberId, @RequestParam Integer blinkerId,
                                  @RequestBody ReportDTO reportDTO) {
        return reportService.submitReport(memberId, blinkerId, reportDTO.getGreenStartTime(),
                reportDTO.getRedStartTime(), reportDTO.getNextGreenStartTime());
    }

    // 특정 사용자의 제보 조회 (해당 사용자가 본인의 제보를 조회)
    @GetMapping("/user/{memberId}")
    public List<ReportDTO> getReportsByMember(@PathVariable Integer memberId) {
        return reportService.getReportsByMember(memberId);
    }

    // 사용자가 처리 상태에 따라 자신의 제보 조회
    @GetMapping("/user/{memberId}/status")
    public List<ReportDTO> getReportsByMemberAndStatus(@PathVariable Integer memberId, @RequestParam ReportStatus status) {
        return reportService.getReportsByMemberAndStatus(memberId, status);
    }


}
