package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.MapResponseDTO;
import com.ddubucks.readygreen.dto.RouteDTO;
import com.ddubucks.readygreen.dto.RouteDTO.FeatureDTO;
import com.ddubucks.readygreen.dto.RouteRequestDTO;
import com.ddubucks.readygreen.model.Blinker;
import com.ddubucks.readygreen.repository.BlinkerRepository;
import com.nimbusds.jose.shaded.gson.Gson;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

@RequiredArgsConstructor
@Service
public class MapService {

    private final static String TYPE = "Point";

    private final BlinkerRepository blinkerRepository;

    @Value("${MAP_SERVICE_KEY}")
    private String mapKey;

    public MapResponseDTO destinationGuide(RouteRequestDTO routeRequestDTO) {

        // 경로 요청
        RouteDTO routeDto = route(routeRequestDTO);

        List<Point> coordinates = getBlinkerCoordinate(routeDto);

        List<Blinker> blinkers = blinkerRepository.findAllByCoordinatesWithinRadius(coordinates, 5);

        return MapResponseDTO.builder()
                .routeDTO(route(routeRequestDTO))
                .build();
    }

    private List<Point> getBlinkerCoordinate(RouteDTO routeDTO) {

        List<Point> coordinates = new ArrayList<>();
        GeometryFactory geometryFactory = new GeometryFactory();

        for (FeatureDTO featureDTO : routeDTO.getFeatures()) {
            if (TYPE.equals(featureDTO.getGeometry().getType()) && isValidTurnType(featureDTO.getProperties().getTurnType())) {
                List<Double> c = (List<Double>) featureDTO.getGeometry().getCoordinates();

                Point point = geometryFactory.createPoint(new Coordinate(c.get(0), c.get(1)));
                coordinates.add(point);
            }
        }
        return coordinates;
    }

    private static boolean isValidTurnType(int turnType) {
        return 211 <= turnType && turnType <= 217;
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
