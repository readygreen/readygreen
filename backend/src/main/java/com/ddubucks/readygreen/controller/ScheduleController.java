package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.AlarmDTO;
import com.ddubucks.readygreen.repository.BookmarkRepository;
import com.ddubucks.readygreen.service.FcmService;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.AllArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import com.ddubucks.readygreen.model.bookmark.Bookmark;

import java.util.List;

@Component
@AllArgsConstructor
public class ScheduleController {
    private final BookmarkRepository bookmarkRepository;
    private final FcmService fcmService;
    @Scheduled(fixedRate = 60000) // 1초마다 실행
    public void fixedDelayJob() throws InterruptedException, FirebaseMessagingException {
        System.out.println("");
        List<AlarmDTO> alarms = bookmarkRepository.findSmartphonesByAlertTime();
        for (AlarmDTO alarm : alarms) {
            fcmService.sendMessageAlarm(alarm);
        }
    }
}
