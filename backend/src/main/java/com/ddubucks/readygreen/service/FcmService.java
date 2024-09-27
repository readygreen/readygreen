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

    public void sendMessageToOtherDevice(Member member, boolean isWatch) throws FirebaseMessagingException {
        System.out.println(member.getNickname()+" ");
        Message message = Message.builder()
                .setToken(isWatch?member.getSmartphone():member.getWatch())
                .putData("type","1")
                .build();
        String response = FirebaseMessaging.getInstance().send(message);
        System.out.println("Successfully sent message: " + response);
    }
}
