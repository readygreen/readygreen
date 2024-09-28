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
import com.ddubucks.readygreen.model.member.Member;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@RestController
@RequestMapping("/fcm")
public class FcmController {
    private final MemberService memberService;
    private final FcmService fcmService;

    @PostMapping("/message")
    public ResponseEntity<?> sendMessage(@AuthenticationPrincipal UserDetails userDetails, @RequestBody FcmRequestDTO fcmRequestDTO){
        try {
            if(fcmRequestDTO.getMessageType()==1){
                Member member = memberService.getMemberInfo(userDetails.getUsername());
                if(member.getSmartphone()==null || member.getWatch()==null){
                    return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
                }
                fcmService.sendMessageToOtherDevice(member, fcmRequestDTO.isWatch());

                return ResponseEntity.status(HttpStatus.OK).body("전송 성공");
            }else{
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

}

