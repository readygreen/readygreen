package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.MainRequest;
import com.ddubucks.readygreen.dto.WeatherResponse;
import com.ddubucks.readygreen.service.MainService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.time.LocalDateTime;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/main")
public class MainController {

    private final MainService mainService;

    @GetMapping("/weather")
    public ResponseEntity<?> weather(@RequestParam("x")String x, @RequestParam("y") String y) throws Exception {
//        List<WeatherResponse> list = mainService.weather(x,y);
//        if(list.isEmpty())return new ResponseEntity<>("날씨 조회 실패", HttpStatus.NOT_FOUND);
//        return ResponseEntity.ok(list);
        List<WeatherResponse> list = mainService.weathers(x,y);
        if(list.isEmpty())return new ResponseEntity<>("날씨 조회 실패", HttpStatus.NOT_FOUND);
        return ResponseEntity.ok(list);
    }

    @GetMapping("/")
    public ResponseEntity<?> mainPage(@RequestParam("x") String x, @RequestParam("y") String y) throws Exception {
        WeatherResponse weatherResponse = mainService.weather(x, y);
        return ResponseEntity.ok(weatherResponse);
    }
}
