package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.service.RedisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/redis")
public class RedisController {

    private final RedisService redisService;

    @Autowired
    public RedisController(RedisService redisService) {
        this.redisService = redisService;
    }

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
