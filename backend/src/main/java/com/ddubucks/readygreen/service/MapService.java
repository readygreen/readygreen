package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.MapResponseDTO;
import com.ddubucks.readygreen.dto.RouteDTO;
import com.ddubucks.readygreen.dto.RouteRequestDTO;
import com.nimbusds.jose.shaded.gson.Gson;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

@RequiredArgsConstructor
@Service
public class MapService {

    @Value("${MAP_SERVICE_KEY}")
    private String mapKey;

    public MapResponseDTO destinationGuide(RouteRequestDTO routeRequestDTO) {

        // 경로 요청
        RouteDTO routeDto = route(routeRequestDTO);

        return MapResponseDTO.builder()
                .routeDTO(route(routeRequestDTO))
                .build();
    }

    @SneakyThrows
    private RouteDTO route(RouteRequestDTO routeRequestDTO) {
        StringBuilder urlBuilder = new StringBuilder("https://apis.openapi.sk.com/tmap/routes/pedestrian"); /*URL*/
        urlBuilder.append("?" + URLEncoder.encode("version", "UTF-8") + "=" + URLEncoder.encode("1", "UTF-8")); /*version*/
        URL url = new URL(urlBuilder.toString());
        System.out.println(url);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-type", "application/json");
        conn.setRequestProperty("appKey", mapKey);
        conn.setRequestProperty("accept", "application/json");

        //request body
        String jsonString = new Gson().toJson(routeRequestDTO);
        conn.setDoOutput(true); /*outputStream을 사용해서 post body 데이터 전송*/
        OutputStream os = conn.getOutputStream();
        os.write(jsonString.getBytes("UTF-8"));

        System.out.println("Response code: " + conn.getResponseCode());
        BufferedReader rd;

        if (conn.getResponseCode() >= 200 && conn.getResponseCode() <= 300) {
            rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        } else {
            throw new RuntimeException(conn.getResponseMessage());
        }

        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = rd.readLine()) != null) {
            sb.append(line + "\n");
        }
        rd.close();
        conn.disconnect();

        String response = sb.toString();
        Gson gson = new Gson();

        return gson.fromJson(response, RouteDTO.class);
    }
}
