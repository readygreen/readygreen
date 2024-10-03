package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.PointRequestDTO;
import com.ddubucks.readygreen.model.Point;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.repository.MemberRepository;
import com.ddubucks.readygreen.repository.PointRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PointService {

    private final PointRepository pointRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public void addPoint(String email, PointRequestDTO pointRequestDTO) {
        Member member = memberRepository.findMemberByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Point point = Point.builder()
                .member(member)
                .description(pointRequestDTO.getDescription())
                .point(pointRequestDTO.getPoint())
                .createDate(LocalDateTime.now())
                .build();

        pointRepository.save(point);

        member.setPoint(member.getPoint() + pointRequestDTO.getPoint());
        memberRepository.save(member);
    }

    public List<Point> getPointsByMember(String email) {
        Member member = memberRepository.findMemberByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return pointRepository.findPointsByMember(member);
    }
}
