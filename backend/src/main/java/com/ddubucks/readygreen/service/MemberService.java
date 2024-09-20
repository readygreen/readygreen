package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.SignupRequestDTO;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.member.Role;
import com.ddubucks.readygreen.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;

    public void signup(SignupRequestDTO signupRequestDTO) {
        memberRepository.save(Member.builder()
                .email(signupRequestDTO.getEmail())
                .nickname(signupRequestDTO.getNickname())
                .socialId(signupRequestDTO.getSocialId())
                .socialType(signupRequestDTO.getSocialType())
                .role(Role.USER)
                .build());
    }

    @Transactional
    public void delete(String email) {
        memberRepository.deleteMemberByEmail(email);
    }
}
