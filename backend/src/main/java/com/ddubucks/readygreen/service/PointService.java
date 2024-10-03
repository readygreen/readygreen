package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.PointRequestDTO;
import com.ddubucks.readygreen.model.Point;
import com.ddubucks.readygreen.model.Step;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.repository.MemberRepository;
import com.ddubucks.readygreen.repository.PointRepository;
import com.ddubucks.readygreen.repository.StepRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PointService {

    private final PointRepository pointRepository;
    private final MemberRepository memberRepository;
    private final StepRepository stepRepository;

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

    public Map<LocalDate, List<Point>> getPointsByMember(String email) {
        Member member = memberRepository.findMemberByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        List<Point> points = pointRepository.findPointsByMember(member);
//        Map<LocalDate, List<Point>> groupedPoints = groupPointsByDate(points);
        return groupPointsByDate(points);
//        groupedPoints.forEach((date, pointList) -> {
//            System.out.println("Date: " + date);
//            for (Point point : pointList) {
//                System.out.println("  " + point.getDescription() + ": " + point.getPoint() + " points");
//            }
//        });
    }
    private Map<LocalDate, List<Point>> groupPointsByDate(List<Point> points) {
        Map<LocalDate, List<Point>> groupedPoints = new HashMap<>();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        for (Point point : points) {
            LocalDate date = point.getCreateDate().toLocalDate();
            groupedPoints.putIfAbsent(date, new ArrayList<>());
            groupedPoints.get(date).add(point);
        }
        return groupedPoints;
    }

//    public List<Step> getStepsByMember(String email){
//        Member member = memberRepository.findMemberByEmail(email)
//                .orElseThrow(() -> new RuntimeException("User not found"));
//        return stepRepository.findByMember;
//    }
}
