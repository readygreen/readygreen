package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Report;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReportRepository extends JpaRepository<Report, Long> {
}
