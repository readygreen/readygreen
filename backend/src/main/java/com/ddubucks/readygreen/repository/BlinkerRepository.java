package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Blinker;
import org.locationtech.jts.geom.Point;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.time.LocalTime;
import java.util.List;

@Repository
public class BlinkerRepository {

    private final JdbcTemplate jdbcTemplate;

    public BlinkerRepository(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    // 좌표 목록과 반경을 받아 해당 범위 내 신호등을 조회하는 메서드
    public List<Blinker> findAllByCoordinatesWithinRadius(List<Point> coordinates, int radius) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM blinker b WHERE ");

        // 좌표 목록에 대해 ST_Distance_Sphere 조건을 반복적으로 추가
        for (int i = 0; i < coordinates.size(); i++) {
            Point coord = coordinates.get(i);
            sql.append("ST_Distance_Sphere(b.coordinate, POINT(")
                    .append(coord.getX()).append(", ").append(coord.getY()).append(")) <= ?");

            if (i < coordinates.size() - 1) {
                sql.append(" OR ");  // 여러 좌표의 결과를 OR로 결합
            }
        }

        // 반경을 파라미터로 설정
        Object[] params = new Object[coordinates.size()];
        for (int i = 0; i < coordinates.size(); i++) {
            params[i] = radius;
        }

        // RowMapper를 사용하여 결과를 객체로 변환
        RowMapper<Blinker> rowMapper = (rs, rowNum) -> {
            return Blinker.builder()
                    .id(rs.getInt("id"))
                    .name(rs.getString("name"))
                    .startTime((LocalTime) rs.getObject("start_time"))
                    .greenDuration(rs.getInt("green_duration"))
                    .redDuration(rs.getInt("red_duration"))
                    .coordinate((Point) rs.getObject("coordinate"))
                    .build();
        };

        return jdbcTemplate.query(sql.toString(), params, rowMapper);
    }
}
