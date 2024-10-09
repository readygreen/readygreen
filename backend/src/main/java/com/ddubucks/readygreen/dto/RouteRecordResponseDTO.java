package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.RouteRecord;
import lombok.*;

import java.util.List;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class RouteRecordResponseDTO {
    List<RouteRecordDTO> routeRecordDTOs;
}
