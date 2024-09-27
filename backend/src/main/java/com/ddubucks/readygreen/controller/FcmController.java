package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.FcmRequestDTO;
import com.ddubucks.readygreen.dto.PointRequestDTO;
import com.ddubucks.readygreen.service.FcmService;
import com.ddubucks.readygreen.service.MemberService;
import com.google.api.Http;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@RestController
@RequestMapping("/fcm")
public class FcmController {
    private final MemberService memberService;
    private final FcmService fcmService;

    @GetMapping("/message")
    public ResponseEntity<?> sendMessage(@AuthenticationPrincipal UserDetails userDetails, @RequestBody FcmRequestDTO fcmRequestDTO){
        try {
            if(fcmRequestDTO.getMessageType()==1){
                fcmService.sendMessageToOtherDevice(memberService.getMemberInfo(userDetails.getUsername()), fcmRequestDTO.isWatch());

                return ResponseEntity.status(HttpStatus.OK).body("전송 성공");
            }else{
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
            }

//            if (!liveScrapUserInfo.isEmpty()) {
//                // FCM 메시지 전송
//                fcmService.sendMessageToMultipleTokens(liveScrapUserInfo, title, liveId);
//
//                // 성공적으로 전송되었을 때, 사용자 정보를 반환
//                return ResponseEntity.status(HttpStatus.OK).body(liveScrapUserInfo);
//            } else {
//                // FCM 정보를 찾지 못한 경우
//                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
//            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

}

