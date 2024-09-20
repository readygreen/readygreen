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

@Service
@RequiredArgsConstructor
public class MainService {

    @Value("${WEATHER_SERVICE_KEY}")
    private String weatherKey;

    public WeatherResponseDTO weather(String x, String y) throws Exception {
        LocalDateTime now = LocalDateTime.now();

        // 년, 월, 일, 시, 분을 추출하여 String으로 변환
        String date = String.format("%04d%02d%02d", now.getYear(), now.getMonthValue(), now.getDayOfMonth());
        String time = String.format("%02d", now.getHour());
        StringBuilder urlBuilder = new StringBuilder("http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"); /*URL*/
        urlBuilder.append("?" + URLEncoder.encode("serviceKey","UTF-8") +"="+ weatherKey); /*Service Key*/
        urlBuilder.append("&" + URLEncoder.encode("pageNo","UTF-8") + "=" + URLEncoder.encode("1", "UTF-8")); /*페이지번호*/
        urlBuilder.append("&" + URLEncoder.encode("numOfRows","UTF-8") + "=" + URLEncoder.encode("1000", "UTF-8")); /*한 페이지 결과 수*/
        urlBuilder.append("&" + URLEncoder.encode("dataType","UTF-8") + "=" + URLEncoder.encode("JSON", "UTF-8")); /*요청자료형식(XML/JSON) Default: XML*/
        urlBuilder.append("&" + URLEncoder.encode("base_date","UTF-8") + "=" + URLEncoder.encode(date, "UTF-8")); /*‘21년 6월 28일 발표*/
        urlBuilder.append("&" + URLEncoder.encode("base_time","UTF-8") + "=" + URLEncoder.encode("0500", "UTF-8")); /*06시 발표(정시단위) */
        urlBuilder.append("&" + URLEncoder.encode("nx","UTF-8") + "=" + URLEncoder.encode(x, "UTF-8")); /*예보지점의 X 좌표값*/
        urlBuilder.append("&" + URLEncoder.encode("ny","UTF-8") + "=" + URLEncoder.encode(y, "UTF-8")); /*예보지점의 Y 좌표값*/
        URL url = new URL(urlBuilder.toString());
        System.out.println(url);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Content-type", "application/json");
        System.out.println("Response code: " + conn.getResponseCode());
        BufferedReader rd;
        if(conn.getResponseCode() >= 200 && conn.getResponseCode() <= 300) {
            rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        } else {
            rd = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
        }
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = rd.readLine()) != null) {
            sb.append(line+"\n");
        }
        rd.close();
        conn.disconnect();

        // JSON 응답 문자열을 파싱
        JSONObject jsonResponse = new JSONObject(sb.toString());
        System.out.println(jsonResponse);
        JSONObject body = jsonResponse.getJSONObject("response").getJSONObject("body");
        JSONArray items = body.getJSONObject("items").getJSONArray("item");
        System.out.println(items);

        // 파싱된 결과 저장을 위한 리스트
        WeatherResponseDTO weatherResponseDTO = new WeatherResponseDTO("",-1,-1,-1);

        // items 배열에서 category와 obsrValue 파싱
        for (int i = 0; i < items.length(); i++) {
            JSONObject item = items.getJSONObject(i);
            String fcstDate = item.getString("fcstDate");
            String fcstTime = item.getString("fcstTime");
            String category = item.getString("category");
            String fcstValue = item.getString("fcstValue");
            if(category.equals("SKY")){
                if(fcstTime.substring(0,2).equals(time)){
                    weatherResponseDTO.setSky(Integer.parseInt(fcstValue));
                }
            }else if(category.equals("POP")){
                if(fcstTime.substring(0,2).equals(time)){
                    weatherResponseDTO.setRainy(Integer.parseInt(fcstValue));
                }
            }else if(category.equals("TMP")){
                if(fcstTime.substring(0,2).equals(time)){
                    weatherResponseDTO.setTemperature(Float.parseFloat(fcstValue));
                }
            }
        }
        System.out.println(weatherResponseDTO);

        return weatherResponseDTO;
    }
    public List<WeatherResponseDTO> weathers(String x, String y) throws Exception{
        LocalDateTime now = LocalDateTime.now();

        // 년, 월, 일, 시, 분을 추출하여 String으로 변환
        String date = String.format("%04d%02d%02d", now.getYear(), now.getMonthValue(), now.getDayOfMonth());
        String time = String.format("%02d", now.getHour());
        StringBuilder urlBuilder = new StringBuilder("http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"); /*URL*/
        urlBuilder.append("?" + URLEncoder.encode("serviceKey","UTF-8") +"="+ weatherKey); /*Service Key*/
        urlBuilder.append("&" + URLEncoder.encode("pageNo","UTF-8") + "=" + URLEncoder.encode("1", "UTF-8")); /*페이지번호*/
        urlBuilder.append("&" + URLEncoder.encode("numOfRows","UTF-8") + "=" + URLEncoder.encode("1000", "UTF-8")); /*한 페이지 결과 수*/
        urlBuilder.append("&" + URLEncoder.encode("dataType","UTF-8") + "=" + URLEncoder.encode("JSON", "UTF-8")); /*요청자료형식(XML/JSON) Default: XML*/
        urlBuilder.append("&" + URLEncoder.encode("base_date","UTF-8") + "=" + URLEncoder.encode(date, "UTF-8")); /*‘21년 6월 28일 발표*/
        urlBuilder.append("&" + URLEncoder.encode("base_time","UTF-8") + "=" + URLEncoder.encode("0500", "UTF-8")); /*06시 발표(정시단위) */
        urlBuilder.append("&" + URLEncoder.encode("nx","UTF-8") + "=" + URLEncoder.encode(x, "UTF-8")); /*예보지점의 X 좌표값*/
        urlBuilder.append("&" + URLEncoder.encode("ny","UTF-8") + "=" + URLEncoder.encode(y, "UTF-8")); /*예보지점의 Y 좌표값*/
        URL url = new URL(urlBuilder.toString());
        System.out.println(url);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Content-type", "application/json");
        System.out.println("Response code: " + conn.getResponseCode());
        BufferedReader rd;
        if(conn.getResponseCode() >= 200 && conn.getResponseCode() <= 300) {
            rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        } else {
            rd = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
        }
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = rd.readLine()) != null) {
            sb.append(line+"\n");
        }
        rd.close();
        conn.disconnect();

        // JSON 응답 문자열을 파싱
        JSONObject jsonResponse = new JSONObject(sb.toString());
        System.out.println(jsonResponse);
        JSONObject body = jsonResponse.getJSONObject("response").getJSONObject("body");
        JSONArray items = body.getJSONObject("items").getJSONArray("item");
        System.out.println(items);

        // 파싱된 결과 저장을 위한 리스트
        List<WeatherResponseDTO> weatherList = new ArrayList<>();

        String current = "";
        WeatherResponseDTO weatherResponseDTO = null;
        // items 배열에서 category와 obsrValue 파싱
        for (int i = 0; i < items.length(); i++) {
            JSONObject item = items.getJSONObject(i);
            String fcstTime = item.getString("fcstTime");
            String category = item.getString("category");
            String fcstValue = item.getString("fcstValue");
            if(category.equals("SKY")){
                if(fcstTime.substring(0,2).equals(current)){
                    weatherResponseDTO.setSky(Integer.parseInt(fcstValue));
                }else{
                    if(weatherResponseDTO !=null)
                        weatherList.add(weatherResponseDTO);
                    weatherResponseDTO = new WeatherResponseDTO();
                    weatherResponseDTO.setTime(fcstTime.substring(0,2));
                    weatherResponseDTO.setSky(Integer.parseInt(fcstValue));
                    current = fcstTime.substring(0,2);
                }
            }else if(category.equals("POP")){
                if(fcstTime.substring(0,2).equals(current)){
                    weatherResponseDTO.setRainy(Integer.parseInt(fcstValue));
                }else{
                    if(weatherResponseDTO !=null)
                        weatherList.add(weatherResponseDTO);
                    weatherResponseDTO = new WeatherResponseDTO();
                    weatherResponseDTO.setTime(fcstTime.substring(0,2));
                    weatherResponseDTO.setRainy(Integer.parseInt(fcstValue));
                    current = fcstTime.substring(0,2);
                }
            }else if(category.equals("TMP")){
                if(fcstTime.substring(0,2).equals(current)){
                    weatherResponseDTO.setTemperature(Float.parseFloat(fcstValue));
                }else{
                    if(weatherResponseDTO !=null)
                        weatherList.add(weatherResponseDTO);
                    weatherResponseDTO = new WeatherResponseDTO();
                    weatherResponseDTO.setTime(fcstTime.substring(0,2));
                    weatherResponseDTO.setTemperature(Float.parseFloat(fcstValue));
                    current = fcstTime.substring(0,2);
                }
            }
            if(weatherList.size()>6){
                return weatherList;
            }
        }

        weatherList.add(weatherResponseDTO);
        System.out.println(weatherList);

        return weatherList;
    }
}
