package com.ddubucks.readygreen.security;


import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;


@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        System.out.println("--loadUserByUsername.java--");

        Member member = memberRepository.findMemberByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("Not found username"));

        System.out.println(member + "member가 정상적으로 나옴");

        return User.builder()
                .username(member.getEmail())
                .password(member.getSocialId())
                .authorities(Collections.singleton(new SimpleGrantedAuthority(member.getRole().getKey())))
                .build();
    }
}
