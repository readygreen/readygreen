package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.RouteRecord;
import com.ddubucks.readygreen.model.bookmark.Bookmark;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class MainResponseDTO {
    private BookmarkResponseDTO bookmarkResponseDTO;
    private RouteRecord routeRecord;
    private WeatherResponseDTO weatherResponseDTO;
}
