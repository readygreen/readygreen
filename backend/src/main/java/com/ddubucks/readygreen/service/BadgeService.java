package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.model.Badge;
import com.ddubucks.readygreen.repository.BadgeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.ddubucks.readygreen.model.member.Member;

@Service
@RequiredArgsConstructor
public class BadgeService {
    private final BadgeRepository badgeRepository;

    public boolean addBadge(String email, int type) {
        Badge badge = badgeRepository.findByMemberEmail(email);
        if (badge == null) {
            throw new IllegalArgumentException("Badge not found for the given email.");
        }
        StringBuilder badgeType = new StringBuilder(badge.getType());
        if (type >= 1 && type <= 3) {
            int index = type - 1;
            if (badgeType.charAt(index) == '0') {
                badgeType.setCharAt(index, '1');
                badge.setType(badgeType.toString());
                badgeRepository.save(badge);
                return true;
            }else{
                return false;
            }
        } else {
            throw new IllegalArgumentException("Invalid badge type. Type must be 1, 2, or 3.");
        }
    }

}
