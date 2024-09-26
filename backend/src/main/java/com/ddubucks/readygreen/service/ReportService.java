package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.ReportDTO;
import com.ddubucks.readygreen.model.Blinker;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.report.Report;
import com.ddubucks.readygreen.model.report.ReportStatus;
import com.ddubucks.readygreen.repository.BlinkerRepository;
import com.ddubucks.readygreen.repository.MemberRepository;
import com.ddubucks.readygreen.repository.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final ReportRepository reportRepository;
    private final MemberRepository memberRepository;
    private final BlinkerRepository blinkerRepository;

    // 사용자가 제보를 제출하는 메서드
    public ReportDTO submitReport(Integer memberId, Integer blinkerId, LocalTime greenStartTime, LocalTime redStartTime, LocalTime nextGreenStartTime) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid member ID"));

//        Blinker blinker = blinkerRepository.findById(blinkerId)
//                .orElseThrow(() -> new IllegalArgumentException("Invalid blinker ID"));

        Report report = Report.builder()
                .member(member)
//                .blinker(blinker)
                .greenStartTime(greenStartTime)
                .redStartTime(redStartTime)
                .nextGreenStartTime(nextGreenStartTime)
                .status(ReportStatus.PENDING)
                .build();

        reportRepository.save(report);
        return mapToReportDTO(report);
    }

    // 모든 제보 조회
    public List<ReportDTO> getAllReports() {
        return reportRepository.findAll().stream()
                .map(this::mapToReportDTO)
                .collect(Collectors.toList());
    }

    // 특정 제보 조회
    public ReportDTO getReportById(Long reportId) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid report ID"));
        return mapToReportDTO(report);
    }

    // 사용자가 제출한 제보 조회
    public List<ReportDTO> getReportsByMember(Integer memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid member ID"));

        return reportRepository.findByMember(member).stream()
                .map(this::mapToReportDTO)
                .collect(Collectors.toList());
    }

    // 사용자가 제출한 제보 조회 (처리 상태별 조회 추가)
    public List<ReportDTO> getReportsByMemberAndStatus(Integer memberId, ReportStatus status) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid member ID"));

        return reportRepository.findByMemberAndStatus(member, status).stream()
                .map(this::mapToReportDTO)
                .collect(Collectors.toList());
    }

    // 관리자가 상태에 따라 제보 조회
    public List<ReportDTO> getReportsByStatus(ReportStatus status) {
        return reportRepository.findByStatus(status).stream()
                .map(this::mapToReportDTO)
                .collect(Collectors.toList());
    }

    // 제보 상태 업데이트
    public ReportDTO updateReportStatus(Long reportId, String status) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid report ID"));

        report.setStatus(ReportStatus.valueOf(status.toUpperCase()));
        reportRepository.save(report);

        return mapToReportDTO(report);
    }

    private ReportDTO mapToReportDTO(Report report) {
        ReportDTO reportDTO = new ReportDTO();
        reportDTO.setId(report.getId());
        reportDTO.setBlinkerId(report.getBlinker().getId());
        reportDTO.setGreenStartTime(report.getGreenStartTime());
        reportDTO.setRedStartTime(report.getRedStartTime());
        reportDTO.setNextGreenStartTime(report.getNextGreenStartTime());
        reportDTO.setStatus(report.getStatus().name());
        reportDTO.setCreatedAt(report.getCreateDate());
        return reportDTO;
    }
}
