package com.ddubucks.readygreen.service;

import com.ddubucks.readygreen.dto.*;
import com.ddubucks.readygreen.dto.RouteDTO.FeatureDTO;
import com.ddubucks.readygreen.exception.UnauthorizedAccessException;
import com.ddubucks.readygreen.model.Blinker;
import com.ddubucks.readygreen.model.RouteRecord;
import com.ddubucks.readygreen.model.bookmark.Bookmark;
import com.ddubucks.readygreen.model.bookmark.BookmarkType;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.repository.*;
import com.nimbusds.jose.shaded.gson.Gson;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.task.TaskExecutionProperties;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.time.Duration;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RequiredArgsConstructor
@Service
public class MapService {

    private final static String TYPE = "Point";
    private final static int RADIUS = 10;
    private static GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    private final BlinkerJDBCRepository blinkerJDBCRepository;
    private final BlinkerRepository blinkerRepository;
    private final RouteRecordRepository routeRecordRepository;
    private final MemberRepository memberRepository;
    private final BookmarkRepository bookmarkRepository;
    private final TaskExecutionProperties taskExecutionProperties;

    @Value("${MAP_SERVICE_KEY}")
    private String mapKey;

    class Node {
        RouteDTO routeDTO;
        int totalSecond;
    }

    public MapResponseDTO getDestinationGuide(RouteRequestDTO routeRequestDTO, String email) {
        // 현재 시간
        LocalTime nowTime = LocalTime.now();

        Node[] routeTotalSecond = new Node[4];

        for (int i = 0; i < 4; i++) {
            routeTotalSecond[i] = new Node();
        }

        // 추천 경로 요청
        routeRequestDTO.searchReco();
        routeTotalSecond[0].routeDTO = route(routeRequestDTO);
        routeTotalSecond[0].totalSecond = getRouteTotalSecond(routeTotalSecond[0].routeDTO, nowTime);

        // 추천 경로 + 대로
        routeRequestDTO.searchRecoAndMainRoad();
        routeTotalSecond[1].routeDTO = route(routeRequestDTO);
        routeTotalSecond[1].totalSecond = getRouteTotalSecond(routeTotalSecond[1].routeDTO, nowTime);

        // 최단 경로
        routeRequestDTO.searchShort();
        routeTotalSecond[2].routeDTO = route(routeRequestDTO);
        routeTotalSecond[2].totalSecond = getRouteTotalSecond(routeTotalSecond[2].routeDTO, nowTime);

        // 최단 경로 + 계단 없음
        routeRequestDTO.searchShortAndNonStair();
        routeTotalSecond[3].routeDTO = route(routeRequestDTO);
        routeTotalSecond[3].totalSecond = getRouteTotalSecond(routeTotalSecond[3].routeDTO, nowTime);

        int minSecondIndex = 0;
        for (int i = 1; i < 4; i++) {
            if (routeTotalSecond[minSecondIndex].totalSecond > routeTotalSecond[i].totalSecond) {
                minSecondIndex = i;
            }
        }

        // 경로 내 신호등 위치
        List<Point> coordinates = getBlinkerCoordinate(routeTotalSecond[minSecondIndex].routeDTO);

        // 해당 좌표의 신호등 정보
        List<Blinker> blinkers = List.of();
        if (!coordinates.isEmpty()) {
            blinkers = blinkerJDBCRepository.findAllByCoordinatesWithinRadius(coordinates, RADIUS);
        }
        // 신호등의 상태 정보
        List<BlinkerDTO> blinkerDTOs = toBlinkerDTOs(blinkers);

        Member member = memberRepository.findMemberByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        // 경로 저장하기
        routeRecordRepository.save(
                RouteRecord.builder()
                        .startName(routeRequestDTO.getStartName())
                        .startCoordinate(getPoint(routeRequestDTO.getStartX(), routeRequestDTO.getStartY()))
                        .endName(routeRequestDTO.getEndName())
                        .endCoordinate(getPoint(routeRequestDTO.getEndX(), routeRequestDTO.getEndY()))
                        .member(member)
                        .build()
        );

        return MapResponseDTO.builder()
                .routeDTO(routeTotalSecond[minSecondIndex].routeDTO)
                .blinkerDTOs(blinkerDTOs)
                .build();
    }

    private int getRouteTotalSecond(RouteDTO routeDTO, LocalTime nowTime) {

        int currentSecond = 0;

        for (FeatureDTO featureDTO : routeDTO.getFeatures()) {
            if (TYPE.equals(featureDTO.getGeometry().getType()) && isValidTurnType(featureDTO.getProperties().getTurnType())) {
                List<Double> c = (List<Double>) featureDTO.getGeometry().getCoordinates();

                //신호등의 현재 시간과 지금까지 걸린 도착 r시간에서 계산
                System.out.println(c.get(0) + " " + c.get(1));
                Blinker blinker = blinkerRepository.findBlinkerNearByCoordinate(c.get(0), c.get(1));

                System.out.println(blinker.getCoordinate().getX() + " " + blinker.getCoordinate().getY());


                // 걸리는 시간getBlinkerTime
                int remainTime = getBlinkerTime(blinker.getStartTime(), nowTime.plusSeconds(currentSecond), blinker.getGreenDuration(), blinker.getRedDuration());

                String status = getBlinkerState(blinker.getStartTime(), nowTime.plusSeconds(currentSecond), blinker.getGreenDuration(), blinker.getRedDuration());

                // 남은 시간이 초록불의 1/3 보다 작으면 다음 빨간불 초 + 파란불 초 값
                if ("GREEN".equals(status) && remainTime < (blinker.getGreenDuration() / 3)) {
                    currentSecond += remainTime + blinker.getRedDuration();
                }

                // 빨간불이면 빨간 불 대기 시간
                else if ("RED".equals(status)) {
                    currentSecond += remainTime;
                }
            }
            if ("LineString".equals(featureDTO.getGeometry().getType())) {
                currentSecond += featureDTO.getProperties().getTime();
            }

        }

        return currentSecond;
    }

    private List<BlinkerDTO> toBlinkerDTOs(List<Blinker> blinkers) {
        List<BlinkerDTO> blinkerDTOs = new ArrayList<>();
        LocalTime nowTime = LocalTime.now();

        // 경로 내 신호등 데이터
        for (Blinker blinker : blinkers) {
            blinkerDTOs.add(
                    BlinkerDTO.builder()
                            .id(blinker.getId())
                            .lastAccessTime(nowTime)
                            .greenDuration(blinker.getGreenDuration())
                            .redDuration(blinker.getRedDuration())
                            .currentState(
                                    getBlinkerState(
                                            blinker.getStartTime(),
                                            nowTime,
                                            blinker.getGreenDuration(),
                                            blinker.getRedDuration()
                                    )
                            )
                            .remainingTime(
                                    getBlinkerTime(
                                            blinker.getStartTime(),
                                            nowTime,
                                            blinker.getGreenDuration(),
                                            blinker.getRedDuration()
                                    )
                            )
                            .latitude(blinker.getCoordinate().getY())
                            .longitude(blinker.getCoordinate().getX())
                            .build()
            );
        }
        return blinkerDTOs;
    }

    private int getBlinkerTime(LocalTime startTime, LocalTime nowTime, int greenDuration, int redDuration) {

        // 시작 시간으로부터 현재까지 경과한 시간 (초 단위)
        long elapsedSeconds = Duration.between(startTime, nowTime).getSeconds();

        int totalCycle = greenDuration + redDuration;

        // 현재 주기 내에서 경과한 시간 계산
        int currentCycleElapsedTime = (int) (elapsedSeconds % totalCycle);

        // 현재 신호 상태와 남은 시간 확인
        if (currentCycleElapsedTime < greenDuration) {
            return greenDuration - currentCycleElapsedTime; // 초록불에서 빨간불로 바뀌기까지 남은 시간
        }
        return totalCycle - currentCycleElapsedTime; // 빨간불에서 초록불로 바뀌기까지 남은 시간
    }

    private String getBlinkerState(LocalTime startTime, LocalTime nowTime, int greenDuration, int redDuration) {

        // 시작 시간으로부터 현재까지 경과한 시간 (초 단위)
        long elapsedSeconds = Duration.between(startTime, nowTime).getSeconds();

        int totalCycle = greenDuration + redDuration;

        // 현재 주기 내에서 경과한 시간 계산
        int currentCycleElapsedTime = (int) (elapsedSeconds % totalCycle);

        // 현재 신호 상태 확인
        if (currentCycleElapsedTime < greenDuration) {
            return "GREEN";
        }
        return "RED";
    }

    private List<Point> getBlinkerCoordinate(RouteDTO routeDTO) {

        List<Point> coordinates = new ArrayList<>();

        for (FeatureDTO featureDTO : routeDTO.getFeatures()) {
            if (TYPE.equals(featureDTO.getGeometry().getType()) && isValidTurnType(featureDTO.getProperties().getTurnType())) {
                List<Double> c = (List<Double>) featureDTO.getGeometry().getCoordinates();

                Point point = getPoint(c.get(0), c.get(1));
                coordinates.add(point);
            }
        }
        return coordinates;
    }

    private static Point getPoint(double longitude, double latitude) {
        return geometryFactory.createPoint(new Coordinate(longitude, latitude));
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

    public BlinkerResponseDTO getNearbyBlinker(double latitude, double longitude, int radius) {
        List<Blinker> blinkers = blinkerJDBCRepository
                .findAllByCoordinatesWithinRadius(getPoint(longitude, latitude), radius);

        return BlinkerResponseDTO.builder()
                .blinkerDTOs(toBlinkerDTOs(blinkers))
                .build();
    }

    public BlinkerResponseDTO getBlinker(List<Integer> blinkerIDs) {
        List<Blinker> blinkers = blinkerRepository.findAllById(blinkerIDs);

        return BlinkerResponseDTO.builder()
                .blinkerDTOs(toBlinkerDTOs(blinkers))
                .build();
    }

    public BookmarkResponseDTO getBookmark(String email) {
        List<Bookmark> bookmarks = bookmarkRepository.findAllByEmailOrderByType(email);

        List<BookmarkDTO> bookmarkDTOs = new ArrayList<>();
        for (Bookmark bookmark : bookmarks) {
            bookmarkDTOs.add(
                    BookmarkDTO
                            .builder()
                            .id(bookmark.getId())
                            .name(bookmark.getName())
                            .destinationName(bookmark.getDestinationName())
                            .latitude(bookmark.getDestinationCoordinate().getY())
                            .longitude(bookmark.getDestinationCoordinate().getX())
                            .alertTime(bookmark.getAlertTime())
                            .placeId(bookmark.getPlaceId())
                            .build()
            );
        }
        return BookmarkResponseDTO.builder()
                .bookmarkDTOs(bookmarkDTOs)
                .build();
    }

    public void saveBookmark(BookmarkRequestDTO bookmarkRequestDTO, String email) {
        Member member = memberRepository.findMemberByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        bookmarkRepository.save(
                Bookmark.builder()
                        .name(bookmarkRequestDTO.getName())
                        .destinationName(bookmarkRequestDTO.getDestinationName())
                        .destinationCoordinate(
                                getPoint(bookmarkRequestDTO.getLongitude(), bookmarkRequestDTO.getLatitude())
                        )
                        .placeId(bookmarkRequestDTO.getPlaceId())
                        .alertTime(bookmarkRequestDTO.getAlertTime())
                        .type(bookmarkRequestDTO.getType())
                        .member(member)
                        .build()
        );
    }


    @SneakyThrows
    @Transactional
    public void deleteBookmark(String placeId, String email) {
        System.out.println(placeId+" "+email);
        boolean exists = bookmarkRepository.existsByPlaceIdAndMemberEmail(placeId, email);
        System.out.println(exists);
        if (!exists) {
            throw new UnauthorizedAccessException("Unauthorized Access");
        }
        bookmarkRepository.deleteByPlaceIdAndMemberEmail(placeId, email);
    }

    public RouteRecordResponseDTO getRouteRecord(String email) {
        return null;
    }

    public Double getDistance(List<FeatureDTO> features) {
        double totalHaversineDistance = 0.0;

        for (int i = 0; i < features.size(); i++) {
            FeatureDTO feature = features.get(i);
            String geometryType = feature.getGeometry().getType();

            if (geometryType.equals("LineString")) {
                List<List<Double>> coordinates = (List<List<Double>>) feature.getGeometry().getCoordinates();
                // 각 좌표 사이의 거리를 계산
                for (int j = 0; j < coordinates.size() - 1; j++) {
                    List<Double> startPoint = coordinates.get(j);
                    List<Double> endPoint = coordinates.get(j + 1);
                    double startX = startPoint.get(0);
                    double startY = startPoint.get(1);
                    double endX = endPoint.get(0);
                    double endY = endPoint.get(1);
                    // 하버사인 거리 계산
                    double haversineDistance = haversineDistance(startY, startX, endY, endX);
                    totalHaversineDistance += haversineDistance;
                }
            }
        }
        System.out.println("Total Haversine Distance: " + totalHaversineDistance + " meters");
        return totalHaversineDistance;
    }

    public double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371000; // 지구 반지름 (미터 단위)
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c; // 거리를 미터로 계산
        return distance;
    }

    @Transactional
    public void updateBookmark(BookmarkEditDTO bookmarkEditDTO, String username) {
        Member member = memberRepository.findMemberByEmail(username)
                .orElseThrow(() -> new IllegalArgumentException("해당 회원이 존재하지 않습니다."));

        Bookmark bookmarkToUpdate = bookmarkRepository.findByIdAndMember(bookmarkEditDTO.getId(), member)
                .orElseThrow(() -> new IllegalArgumentException("해당 북마크가 존재하지 않습니다."));

        BookmarkType newType = bookmarkEditDTO.getType();

        // 'HOME'이나 'COMPANY'로 변경하려고 할 때, 기존에 해당 타입이 이미 존재하면 ETC로 변경
        if (newType == BookmarkType.HOME || newType == BookmarkType.COMPANY) {
            Optional<Bookmark> existingBookmark = bookmarkRepository.findByTypeAndMember(newType, member);

            if (existingBookmark.isPresent() && existingBookmark.get().getId() != bookmarkToUpdate.getId()) {
                Bookmark existing = existingBookmark.get();
                existing.setName("기타");
                existing.setType(BookmarkType.ETC); // 기존 집이나 회사 북마크를 'ETC'로 변경
                bookmarkRepository.save(existing);
            }
        }

        // 선택한 북마크의 타입을 새로운 타입으로 변경
        bookmarkToUpdate.setType(newType);
        bookmarkToUpdate.setName(newType.getTitle());
        bookmarkRepository.save(bookmarkToUpdate);
    }

}
