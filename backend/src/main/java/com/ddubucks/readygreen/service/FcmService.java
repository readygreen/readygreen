package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.AlarmDTO;
import com.ddubucks.readygreen.model.bookmark.Bookmark;
import com.ddubucks.readygreen.model.member.Member;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;


@Service
@RequiredArgsConstructor
public class FcmService {
    private final MemberService memberService;

    public void sendMessageToOtherDevice(Member member, boolean isWatch, int type) throws FirebaseMessagingException {
        // type 1 : 안내 시작
        // type 2 : 안내 끝
        try {
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
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public void sendMessageAlarm(AlarmDTO alarm) throws FirebaseMessagingException{
        try{
            Bookmark bookmark  = alarm.getBookmark();
            Message message = Message.builder()
                    .setToken(alarm.getSmartphones())
                    .putData("type","3")
                    .putData("point",bookmark.getDestinationCoordinate().toString())
                    .putData("destinationName", bookmark.getDestinationName())
                    .build();
            String response = FirebaseMessaging.getInstance().send(message);

            // 로그 출력
            System.out.println("전송한 토큰: " + alarm.getSmartphones());
            System.out.println("Successfully sent message: " + response);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
