package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Badge;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BadgeRepository extends JpaRepository<Badge, Integer> {
    Badge findByMemberEmail(String username);
    int findBadgeTypeByMemberEmail(String email);
}
