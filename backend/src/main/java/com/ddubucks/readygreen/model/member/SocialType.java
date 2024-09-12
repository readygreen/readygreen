package com.ddubucks.readygreen.model.member;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum SocialType {
    GOOGLE("google", "구글 로그인"),
    NAVER("naver", "네이버 로그인"),
    KAKAO("kakao", "카카오 로그인");

    private final String key;
    private final String title;
}