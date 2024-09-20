package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Notice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NoticeRepository extends JpaRepository<Notice, Integer> {
    // 중요 공지사항은 맨 위에 정렬하고, 그 뒤에 일반 공지사항을 정렬
    List<Notice> findAllByOrderByIsImportantDescCreateDateDesc();
}
