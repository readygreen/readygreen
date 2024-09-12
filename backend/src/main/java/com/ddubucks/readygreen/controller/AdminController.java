//package com.ddubucks.readygreen.controller;
//
//import com.ddubucks.readygreen.dto.AnnouncementDTO;
//import com.ddubucks.readygreen.dto.InquiryDTO;
//import com.ddubucks.readygreen.dto.ReportDTO;
//import com.ddubucks.readygreen.service.AnnouncementService;
//import com.ddubucks.readygreen.service.InquiryService;
//import com.ddubucks.readygreen.service.ReportService;
//import io.swagger.v3.oas.annotations.parameters.RequestBody;
//import lombok.RequiredArgsConstructor;
//import org.springframework.web.bind.annotation.*;
//
//import java.util.List;
//
//@RestController
//@RequestMapping("/api/v1/admin")
//@RequiredArgsConstructor
//public class AdminController {
//
//    private final AnnouncementService announcementService;
//    private final InquiryService inquiryService;
//    private final ReportService reportService;
//
//    // 공지사항 목록 조회
//    @GetMapping("/notice")
//    public List<AnnouncementDTO> getNotices() {
//        return announcementService.getAllAnnouncements();
//    }
//
//    // 공지사항 상세 조회
//    @GetMapping("/notice/detail")
//    public AnnouncementDTO getNoticeDetail(@RequestParam Long id) {
//        return announcementService.getAnnouncementById(id);
//    }
//
//    // 공지사항 작성 (관리자 전용)
////    @PreAuthorize("hasRole('ADMIN')")
//    @PostMapping("/notice")
//    public void createNotice(@RequestBody AnnouncementDTO announcementDTO, @RequestParam Long authorId) {
//        announcementService.createAnnouncement(announcementDTO, authorId);
//    }
//
//    // 문의사항 목록 조회 (관리자 전용)
////    @PreAuthorize("hasRole('ADMIN')")
//    @GetMapping("/feedback")
//    public List<InquiryDTO> getFeedbacks() {
//        return inquiryService.getAllInquiries();
//    }
//
//    // 문의사항 답변하기 (관리자 전용)
////    @PreAuthorize("hasRole('ADMIN')")
//    @PostMapping("/feedback")
//    public void answerFeedback(@RequestParam Long inquiryId, @RequestBody String answer) {
//        inquiryService.answerInquiry(inquiryId, answer);
//    }
//
//    // 제보 목록 조회 (관리자 전용)
////    @PreAuthorize("hasRole('ADMIN')")
//    @GetMapping("/report")
//    public List<ReportDTO> getReports() {
//        return reportService.getAllReports();
//    }
//
//    // 제보 승인하기 (관리자 전용)
////    @PreAuthorize("hasRole('ADMIN')")
//    @PostMapping("/report")
//    public void approveReport(@RequestParam Long reportId) {
//        reportService.approveReport(reportId);
//    }
//}
