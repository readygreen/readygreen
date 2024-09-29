package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.WeatherResponseDTO;
import lombok.RequiredArgsConstructor;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;


import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDateTime;
import io.github.flashvayne.chatgpt.service.ChatgptService;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MainService {

    @Value("${WEATHER_SERVICE_KEY}")
    private String weatherKey;
    private final ChatgptService chatgptService;

    public String getFortune(String prompt) {
//        Map<String, Object> requestBody = new HashMap<>();
//        requestBody.put("model", "gpt-3.5-turbo");
//        requestBody.put("prompt", prompt);
//        requestBody.put("max_tokens", 150);
//        requestBody.put("temperature", 1.0);
        return chatgptService.sendMessage(prompt);
    }
    public WeatherResponseDTO weather(String x, String y) throws Exception {
        LocalDateTime now = LocalDateTime.now();
        now = now.minusHours(1);
        System.out.println(now);

        // 년, 월, 일, 시, 분을 추출하여 String으로 변환
        String date = String.format("%04d%02d%02d", now.getYear(), now.getMonthValue(), now.getDayOfMonth());
        String time = String.format("%02d", now.getHour());
        String baseTime = String.format("%02d00", now.getHour());; // 기본 base_time 설정

        WeatherResponseDTO weatherResponseDTO = null;

        for (int retry = 0; retry < 5; retry++) { // 데이터가 없을 경우 1시간 전으로 다시 시도
            StringBuilder urlBuilder = new StringBuilder("http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"); /*URL*/
            urlBuilder.append("?" + URLEncoder.encode("serviceKey", "UTF-8") + "=" + weatherKey); /*Service Key*/
            urlBuilder.append("&" + URLEncoder.encode("pageNo", "UTF-8") + "=" + URLEncoder.encode("1", "UTF-8")); /*페이지번호*/
            urlBuilder.append("&" + URLEncoder.encode("numOfRows", "UTF-8") + "=" + URLEncoder.encode("200", "UTF-8")); /*한 페이지 결과 수*/
            urlBuilder.append("&" + URLEncoder.encode("dataType", "UTF-8") + "=" + URLEncoder.encode("JSON", "UTF-8")); /*요청자료형식(XML/JSON) Default: XML*/
            urlBuilder.append("&" + URLEncoder.encode("base_date", "UTF-8") + "=" + URLEncoder.encode(date, "UTF-8")); /*‘21년 6월 28일 발표*/
            urlBuilder.append("&" + URLEncoder.encode("base_time", "UTF-8") + "=" + URLEncoder.encode(baseTime, "UTF-8")); /*06시 발표(정시단위)*/
            urlBuilder.append("&" + URLEncoder.encode("nx", "UTF-8") + "=" + URLEncoder.encode(x, "UTF-8")); /*예보지점의 X 좌표값*/
            urlBuilder.append("&" + URLEncoder.encode("ny", "UTF-8") + "=" + URLEncoder.encode(y, "UTF-8")); /*예보지점의 Y 좌표값*/

            URL url = new URL(urlBuilder.toString());
            System.out.println(url);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Content-type", "application/json");
            System.out.println("Response code: " + conn.getResponseCode());
            BufferedReader rd;
            if (conn.getResponseCode() >= 200 && conn.getResponseCode() <= 300) {
                rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            } else {
                rd = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
            }
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = rd.readLine()) != null) {
                sb.append(line + "\n");
            }
            rd.close();
            conn.disconnect();

            // JSON 응답 문자열을 파싱
            JSONObject jsonResponse = new JSONObject(sb.toString());
            System.out.println(jsonResponse);

            // 결과가 없는 경우(resultCode가 "03")면 1시간 전으로 다시 시도
            String resultCode = jsonResponse.getJSONObject("response").getJSONObject("header").getString("resultCode");
            if (resultCode.equals("03")) {
                // 1시간 전으로 다시 시도
                now = now.minusHours(1);
                date = String.format("%04d%02d%02d", now.getYear(), now.getMonthValue(), now.getDayOfMonth());
                baseTime = String.format("%02d00", now.getHour()); // base_time을 1시간 전으로 변경
                System.out.println(baseTime);
                continue;
            }

            // 정상적인 응답이 있을 경우
            JSONObject body = jsonResponse.getJSONObject("response").getJSONObject("body");
            JSONArray items = body.getJSONObject("items").getJSONArray("item");
            System.out.println(items);

            weatherResponseDTO = new WeatherResponseDTO("", -1, -1, -1);

            // items 배열에서 category와 obsrValue 파싱
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);
                String fcstDate = item.getString("fcstDate");
                String fcstTime = item.getString("fcstTime");
                String category = item.getString("category");
                String fcstValue = item.getString("fcstValue");
                if (category.equals("SKY")) {
                    if (fcstTime.substring(0, 2).equals(time)) {
                        weatherResponseDTO.setSky(Integer.parseInt(fcstValue));
                    }
                } else if (category.equals("POP")) {
                    if (fcstTime.substring(0, 2).equals(time)) {
                        weatherResponseDTO.setRainy(Integer.parseInt(fcstValue));
                    }
                } else if (category.equals("TMP")) {
                    if (fcstTime.substring(0, 2).equals(time)) {
                        weatherResponseDTO.setTemperature(Float.parseFloat(fcstValue));
                    }
                }
            }

            // 데이터가 존재하면 반환
            if (weatherResponseDTO != null) {
                break;
            }
        }

        System.out.println(weatherResponseDTO);
        return weatherResponseDTO;
    }

    public List<WeatherResponseDTO> weathers(String x, String y) throws Exception {
        LocalDateTime now = LocalDateTime.now();
        now = now.minusHours(1);

        // 년, 월, 일, 시를 추출하여 String으로 변환
        String date = String.format("%04d%02d%02d", now.getYear(), now.getMonthValue(), now.getDayOfMonth());
        String baseTime = String.format("%02d00", now.getHour()); // 기본 base_time 설정

        List<WeatherResponseDTO> weatherList = new ArrayList<>();

        for (int retry = 0; retry < 5; retry++) { // 데이터가 없을 경우 1시간 전으로 다시 시도
            StringBuilder urlBuilder = new StringBuilder("http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"); /*URL*/
            urlBuilder.append("?" + URLEncoder.encode("serviceKey", "UTF-8") + "=" + weatherKey); /*Service Key*/
            urlBuilder.append("&" + URLEncoder.encode("pageNo", "UTF-8") + "=" + URLEncoder.encode("1", "UTF-8")); /*페이지번호*/
            urlBuilder.append("&" + URLEncoder.encode("numOfRows", "UTF-8") + "=" + URLEncoder.encode("1000", "UTF-8")); /*한 페이지 결과 수*/
            urlBuilder.append("&" + URLEncoder.encode("dataType", "UTF-8") + "=" + URLEncoder.encode("JSON", "UTF-8")); /*요청자료형식(XML/JSON) Default: XML*/
            urlBuilder.append("&" + URLEncoder.encode("base_date", "UTF-8") + "=" + URLEncoder.encode(date, "UTF-8")); /*‘21년 6월 28일 발표*/
            urlBuilder.append("&" + URLEncoder.encode("base_time", "UTF-8") + "=" + URLEncoder.encode(baseTime, "UTF-8")); /*정시단위 */
            urlBuilder.append("&" + URLEncoder.encode("nx", "UTF-8") + "=" + URLEncoder.encode(x, "UTF-8")); /*예보지점의 X 좌표값*/
            urlBuilder.append("&" + URLEncoder.encode("ny", "UTF-8") + "=" + URLEncoder.encode(y, "UTF-8")); /*예보지점의 Y 좌표값*/
            URL url = new URL(urlBuilder.toString());
            System.out.println(url);

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Content-type", "application/json");
            System.out.println("Response code: " + conn.getResponseCode());
            BufferedReader rd;
            if (conn.getResponseCode() >= 200 && conn.getResponseCode() <= 300) {
                rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            } else {
                rd = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
            }

            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = rd.readLine()) != null) {
                sb.append(line + "\n");
            }
            rd.close();
            conn.disconnect();

            // JSON 응답 문자열을 파싱
            JSONObject jsonResponse = new JSONObject(sb.toString());
            System.out.println(jsonResponse);

            // 결과가 없는 경우(resultCode가 "03")면 1시간 전으로 다시 시도
            String resultCode = jsonResponse.getJSONObject("response").getJSONObject("header").getString("resultCode");
            if (resultCode.equals("03")) {
                // 1시간 전으로 다시 시도
                now = now.minusHours(1);

                date = String.format("%04d%02d%02d", now.getYear(), now.getMonthValue(), now.getDayOfMonth());
                baseTime = String.format("%02d00", now.getHour()); // base_time을 1시간 전으로 변경
                System.out.println("시간"+baseTime);
                continue;
            }

            // 정상적인 응답이 있을 경우 데이터 파싱
            JSONObject body = jsonResponse.getJSONObject("response").getJSONObject("body");
            JSONArray items = body.getJSONObject("items").getJSONArray("item");
            System.out.println(items);

            String current = "";
            WeatherResponseDTO weatherResponseDTO = null;

            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);
                String fcstTime = item.getString("fcstTime");
                String category = item.getString("category");
                String fcstValue = item.getString("fcstValue");

                if (category.equals("SKY")) {
                    if (fcstTime.substring(0, 2).equals(current)) {
                        weatherResponseDTO.setSky(Integer.parseInt(fcstValue));
                    } else {
                        if (weatherResponseDTO != null)
                            weatherList.add(weatherResponseDTO);
                        weatherResponseDTO = new WeatherResponseDTO();
                        weatherResponseDTO.setTime(fcstTime.substring(0, 2));
                        weatherResponseDTO.setSky(Integer.parseInt(fcstValue));
                        current = fcstTime.substring(0, 2);
                    }
                } else if (category.equals("POP")) {
                    if (fcstTime.substring(0, 2).equals(current)) {
                        weatherResponseDTO.setRainy(Integer.parseInt(fcstValue));
                    } else {
                        if (weatherResponseDTO != null)
                            weatherList.add(weatherResponseDTO);
                        weatherResponseDTO = new WeatherResponseDTO();
                        weatherResponseDTO.setTime(fcstTime.substring(0, 2));
                        weatherResponseDTO.setRainy(Integer.parseInt(fcstValue));
                        current = fcstTime.substring(0, 2);
                    }
                } else if (category.equals("TMP")) {
                    if (fcstTime.substring(0, 2).equals(current)) {
                        weatherResponseDTO.setTemperature(Float.parseFloat(fcstValue));
                    } else {
                        if (weatherResponseDTO != null)
                            weatherList.add(weatherResponseDTO);
                        weatherResponseDTO = new WeatherResponseDTO();
                        weatherResponseDTO.setTime(fcstTime.substring(0, 2));
                        weatherResponseDTO.setTemperature(Float.parseFloat(fcstValue));
                        current = fcstTime.substring(0, 2);
                    }
                }

                if (weatherList.size() > 6) {
                    return weatherList;
                }
            }

            weatherList.add(weatherResponseDTO);
            System.out.println(weatherList);

            // 데이터가 존재하면 반환
            if (!weatherList.isEmpty()) {
                break;
            }
        }

        return weatherList;
    }

}
