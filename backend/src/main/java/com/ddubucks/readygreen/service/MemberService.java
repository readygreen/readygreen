package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.SignupRequestDTO;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.model.member.Role;
import com.ddubucks.readygreen.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public void signup(SignupRequestDTO signupRequestDTO) {
        memberRepository.save(Member.builder()
                .email(signupRequestDTO.getEmail())
                .nickname(signupRequestDTO.getNickname())
                .birth(signupRequestDTO.getBirth())
                .socialId(passwordEncoder.encode(signupRequestDTO.getSocialId()))
                .socialType(signupRequestDTO.getSocialType())
                .role(Role.USER)
                .build());
    }

    @Transactional
    public void delete(String email) {
        memberRepository.deleteMemberByEmail(email);
    }
}
