package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.service.RedisService;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/redis")
@AllArgsConstructor
public class RedisController {

    private final RedisService redisService;


    @PostMapping("/save")
    public String saveToRedis(@RequestParam String key, @RequestParam String value) {

        redisService.save(key, value);
        return "Data saved successfully!";
    }

    @GetMapping("/get")
    public Object getFromRedis(@RequestParam String key) {
        return redisService.find(key);
    }

    @DeleteMapping("/delete")
    public String deleteFromRedis(@RequestParam String key) {
        redisService.delete(key);
        return "Data deleted successfully!";
    }
}
