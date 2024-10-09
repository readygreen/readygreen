package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.PointRequestDTO;
import com.ddubucks.readygreen.dto.ReportBlinkerRequestDTO;
import com.ddubucks.readygreen.dto.ReportDTO;
import com.ddubucks.readygreen.model.report.ReportStatus;
import com.ddubucks.readygreen.service.PointService;
import com.ddubucks.readygreen.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/report")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;
    private final PointService pointService;

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

    // 사용자가 신호등 제보 + 반영
    @PutMapping("blinker")
    public ResponseEntity<String> submitBlinker(@AuthenticationPrincipal UserDetails userDetails, @RequestBody ReportBlinkerRequestDTO reportBlinkerRequestDTO){
        try {
            // 신호등 정보 업데이트
            reportService.updatePeriod(reportBlinkerRequestDTO);
            // 포인트 추가
            PointRequestDTO pointRequestDTO = PointRequestDTO.builder()
                    .point(300)
                    .description("제보 신호등 제보")
                    .build();
            pointService.addPoint(userDetails.getUsername(), pointRequestDTO);

            // 성공적으로 처리된 경우
            return ResponseEntity.ok("신호등 데이터가 반영되었습니다.");
        } catch (IllegalArgumentException e) {
            // 신호등이 존재하지 않을 때 예외 처리
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            // 기타 예외 처리
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류가 발생했습니다.");
        }
    }
}
