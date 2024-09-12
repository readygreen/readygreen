//package com.ddubucks.readygreen.service;
//
//import com.ddubucks.readygreen.dto.AnnouncementDTO;
//import com.ddubucks.readygreen.model.Announcement;
//import com.ddubucks.readygreen.model.member.Member;
//import com.ddubucks.readygreen.repository.AnnouncementRepository;
////import com.ddubucks.readygreen.repository.MemberRepository;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//import java.time.LocalDateTime;
//import java.util.List;
//import java.util.stream.Collectors;
//
//@Service
//@RequiredArgsConstructor
//public class AnnouncementService {
//
//    private final AnnouncementRepository announcementRepository;
////    private final MemberRepository memberRepository;
//
//    public void createAnnouncement(AnnouncementDTO announcementDTO, Long authorId) {
////        Member author = memberRepository.findById(authorId)
////                .orElseThrow(() -> new IllegalArgumentException("Author not found"));
//
//        Announcement announcement = Announcement.builder()
//                .title(announcementDTO.getTitle())
//                .content(announcementDTO.getContent())
//                .createdAt(LocalDateTime.now())
//                .isImportant(announcementDTO.isImportant())
////                .author(author)
//                .build();
//        announcementRepository.save(announcement);
//    }
//
//    public void updateAnnouncement(Long id, AnnouncementDTO announcementDTO) {
//        Announcement announcement = announcementRepository.findById(id)
//                .orElseThrow(() -> new IllegalArgumentException("Announcement not found"));
//
//        announcement.setTitle(announcementDTO.getTitle());
//        announcement.setContent(announcementDTO.getContent());
//        announcement.setImportant(announcementDTO.isImportant());
//        announcementRepository.save(announcement);
//    }
//
//    public void deleteAnnouncement(Long id) {
//        announcementRepository.deleteById(id);
//    }
//
//    public List<AnnouncementDTO> getAllAnnouncements() {
//        List<Announcement> announcements = announcementRepository.findAllOrderedByImportanceAndDate();
//        return announcements.stream().map(this::convertToDTO).collect(Collectors.toList());
//    }
//
//    public AnnouncementDTO getAnnouncementById(Long id) {
//        Announcement announcement = announcementRepository.findById(id)
//                .orElseThrow(() -> new IllegalArgumentException("Announcement not found"));
//        return convertToDTO(announcement);
//    }
//
//    private AnnouncementDTO convertToDTO(Announcement announcement) {
//        return AnnouncementDTO.builder()
//                .id(announcement.getId())
//                .title(announcement.getTitle())
//                .content(announcement.getContent())
//                .createdAt(announcement.getCreatedAt())
//                .isImportant(announcement.isImportant())
//                .authorName("관리자")  // 작성자는 무조건 "관리자"로 표시
//                .build();
//    }
//
//}
