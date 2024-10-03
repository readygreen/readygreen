package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.NoticeRequestDTO;
import com.ddubucks.readygreen.dto.NoticeResponseDTO;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.Notice;
import com.ddubucks.readygreen.repository.MemberRepository;
import com.ddubucks.readygreen.repository.NoticeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NoticeService {

    private final NoticeRepository noticeRepository;
    private final MemberRepository memberRepository;

    // 공지사항 작성 (관리자만)
    public NoticeResponseDTO createNotice(NoticeRequestDTO requestDTO, String userEmail) {
        Member admin = memberRepository.findMemberByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("Admin not found"));

        Notice notice = Notice.builder()
                .title(requestDTO.getTitle())
                .content(requestDTO.getContent())
                .isImportant(requestDTO.isImportant())
                .member(admin)
                .build();

        noticeRepository.save(notice);
        return mapToResponseDTO(notice);
    }

    // 공지사항 수정 (관리자만)
    public NoticeResponseDTO updateNotice(int id, NoticeRequestDTO requestDTO, String userEmail) {
        Notice notice = noticeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notice not found"));

        notice.setTitle(requestDTO.getTitle());
        notice.setContent(requestDTO.getContent());
        notice.setImportant(requestDTO.isImportant());
        noticeRepository.save(notice);

        return mapToResponseDTO(notice);
    }

    // 공지사항 삭제 (관리자만)
    public void deleteNotice(int id, String userEmail) {
        Notice notice = noticeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notice not found"));

        noticeRepository.delete(notice);
    }

    // 공지사항 목록 조회 (중요한 공지사항은 위에 표시)
    public List<NoticeResponseDTO> getAllNotices() {
        return noticeRepository.findAllByOrderByIsImportantDescCreateDateDesc().stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    // 공지사항 상세 조회
    public NoticeResponseDTO getNoticeById(int id) {
        Notice notice = noticeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notice not found"));

        return mapToResponseDTO(notice);
    }

    // Helper method to convert entity to DTO
    private NoticeResponseDTO mapToResponseDTO(Notice notice) {
        NoticeResponseDTO responseDTO = new NoticeResponseDTO();
        responseDTO.setId(notice.getId());
        responseDTO.setTitle(notice.getTitle());
        responseDTO.setContent(notice.getContent());
        responseDTO.setCreateDate(notice.getCreateDate());
        responseDTO.setAuthor(notice.getMember().getNickname());  // 작성자 이름 설정
        responseDTO.setImportant(notice.isImportant());
        return responseDTO;
    }
}
