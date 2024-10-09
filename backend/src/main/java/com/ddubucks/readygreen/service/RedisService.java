package com.ddubucks.readygreen.service;
import com.ddubucks.readygreen.dto.MapResponseDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.concurrent.TimeUnit;

@Service
@AllArgsConstructor
public class RedisService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final ObjectMapper objectMapper;


    public void save(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    public void saveWithTimeout(String key, String value) {
        redisTemplate.opsForValue().set(key, value, 5, TimeUnit.MINUTES);
    }

    public Object find(String key) {
        System.out.println("find"+key);
        return redisTemplate.opsForValue().get(key);
    }

    public void delete(String key) {
        redisTemplate.delete(key);
    }

    public boolean hasKey(String key) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    public MapResponseDTO findMap(String key) {
        // Redis에서 직렬화된 데이터를 가져옴
        Object serializedData = redisTemplate.opsForValue().get(key);

        if (serializedData != null && serializedData instanceof LinkedHashMap) {
            try {
                // LinkedHashMap을 MapResponseDTO로 변환
                return objectMapper.convertValue(serializedData, MapResponseDTO.class);
            } catch (Exception e) {
                e.printStackTrace();
                return null; // 역직렬화 실패 시 null 반환
            }
        } else if (serializedData != null && serializedData instanceof String) {
            // 만약 String 타입이라면, 이때는 다른 처리가 필요할 수 있음
            System.out.println("데이터가 문자열 형식입니다: " + serializedData);
            return null;
        } else {
            System.out.println("Redis에서 데이터를 찾을 수 없습니다.");
            return null;
        }
    }
}
