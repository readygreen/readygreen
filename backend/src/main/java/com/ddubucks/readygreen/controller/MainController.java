package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.WeatherResponseDTO;
import com.ddubucks.readygreen.service.MainService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
        List<WeatherResponseDTO> list = mainService.weathers(x,y);
        if(list.isEmpty())return new ResponseEntity<>("날씨 조회 실패", HttpStatus.NOT_FOUND);
        return ResponseEntity.ok(list);
    }

    @GetMapping("/")
    public ResponseEntity<?> mainPage(@RequestParam("x") String x, @RequestParam("y") String y) throws Exception {
        WeatherResponseDTO weatherResponseDTO = mainService.weather(x, y);
        return ResponseEntity.ok(weatherResponseDTO);
    }
}
