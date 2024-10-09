package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.report.Report;
import com.ddubucks.readygreen.model.report.ReportStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReportRepository extends JpaRepository<Report, Long> {
    List<Report> findByMember(Member member);
    List<Report> findByStatus(ReportStatus status);
    List<Report> findByMemberAndStatus(Member member, ReportStatus status);
}
