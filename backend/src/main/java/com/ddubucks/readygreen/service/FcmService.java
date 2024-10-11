package com.ddubucks.readygreen.service;

import com.google.firebase.messaging.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import com.ddubucks.readygreen.model.member.Member;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;


@Service
@RequiredArgsConstructor
public class FcmService {
    private final MemberService memberService;

    public void sendMessageToOtherDevice(Member member, boolean isWatch, int type) throws FirebaseMessagingException {
        // type 1 : 안내 시작
        // type 2 : 안내 끝

        // 스마트폰 또는 워치에 전송할 토큰 선택
        String deviceToken = !isWatch ? member.getWatch() : member.getSmartphone();

        if (deviceToken == null || deviceToken.isEmpty()) {
            System.out.println("토큰이 유효하지 않습니다. 알림을 보낼 수 없습니다.");
            return;
        }

        // FCM 메시지 빌드
        Message message = Message.builder()
                .setToken(deviceToken)
                .putData("type", String.valueOf(type))
                .build();

        // FCM 메시지 전송
        String response = FirebaseMessaging.getInstance().send(message);

        // 로그 출력
        System.out.println("보낸 대상: " + (!isWatch ? "워치" : "스마트폰"));
        System.out.println("전송한 토큰: " + deviceToken);
        System.out.println("Successfully sent message: " + response);
    }
}
