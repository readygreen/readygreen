package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.BadgeResponseDTO;
import com.ddubucks.readygreen.model.Badge;
import com.ddubucks.readygreen.model.Point;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.repository.BadgeRepository;
import com.ddubucks.readygreen.repository.MemberRepository;
import com.ddubucks.readygreen.repository.PointRepository;
import com.ddubucks.readygreen.service.BadgeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequiredArgsConstructor
@RequestMapping("/badge")
public class BadgeController {
    private final BadgeRepository badgeRepository;
    private final BadgeService badgeService;
    private final MemberRepository memberRepository;

    @GetMapping
    public ResponseEntity<BadgeResponseDTO> getBadge(@AuthenticationPrincipal UserDetails userDetails) {
        // findByMemberEmail의 반환값을 저장
        Badge badge = badgeRepository.findByMemberEmail(userDetails.getUsername());
        // Badge가 없을 경우 처리
        if (badge == null) {
            return ResponseEntity.status(HttpStatus.NO_CONTENT).body(null);
        }
        // Badge 데이터에 따라 BadgeResponseDTO를 생성
        BadgeResponseDTO badgeResponseDTO = BadgeResponseDTO.builder()
                .type(badge.getType()) // badge에서 타입을 가져와서 설정
                .title(badge.getTitle()) // badge에서 제목을 가져와서 설정
                .build();
        // 응답 객체 반환
        return ResponseEntity.ok(badgeResponseDTO);
    }

    @PostMapping
    public ResponseEntity<String> editTitle(@AuthenticationPrincipal UserDetails userDetails, @RequestParam(name = "title") int title){
        Badge badge = badgeRepository.findByMemberEmail(userDetails.getUsername());
        if (badge == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("뱃지가 아직 없습니다!");
        }
        badge.setTitle(title);
        badgeRepository.save(badge);
        return ResponseEntity.ok("메인 뱃지 수정 성공");
    }

    @PostMapping("fortune")
    public ResponseEntity<String> editBadge(@AuthenticationPrincipal UserDetails userDetails){
        if(badgeService.addBadge(userDetails.getUsername(),1)) {
            return ResponseEntity.ok("운세 뱃지 획득!!");
        }else{
            return ResponseEntity.status(HttpStatus.CONFLICT).body("이미 얻었어요ㅠㅠ");
        }
    }

    @PostMapping("point")
    public ResponseEntity<String> checkPoint(@AuthenticationPrincipal UserDetails userDetails) {
        Optional<Member> optionalMember = memberRepository.findMemberByEmail(userDetails.getUsername());
        if (optionalMember.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("회원 정보를 찾을 수 없습니다.");
        }
        Member member = optionalMember.get();
        if (member.getPoint() > 10000) {
            if (badgeService.addBadge(userDetails.getUsername(), 3)) {
                return ResponseEntity.ok("포인트 뱃지 획득!!");
            } else {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("이미 얻었어요ㅠㅠ");
            }
        } else {
            return ResponseEntity.status(HttpStatus.PAYMENT_REQUIRED).body("포인트가 부족해요ㅠㅠ");
        }
    }
    @PostMapping("step")
    public ResponseEntity<String> checkStep(@AuthenticationPrincipal UserDetails userDetails) {
        Optional<Member> optionalMember = memberRepository.findMemberByEmail(userDetails.getUsername());
        if (optionalMember.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("회원 정보를 찾을 수 없습니다.");
        }
        Member member = optionalMember.get();
        if (member.getStep() > 10000) {
            if (badgeService.addBadge(userDetails.getUsername(), 2)) {
                return ResponseEntity.ok("걸음수 뱃지 획득!!");
            } else {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("이미 얻었어요ㅠㅠ");
            }
        } else {
            return ResponseEntity.status(HttpStatus.PAYMENT_REQUIRED).body("걸음수가 부족해요ㅠㅠ");
        }
    }



}
