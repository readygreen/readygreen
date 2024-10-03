package com.ddubucks.readygreen.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class RouteDTO {
    private String type;
    private List<FeatureDTO> features;

    @NoArgsConstructor
    @AllArgsConstructor
    @Getter
    @Setter
    public class FeatureDTO {
        private String type;
        private GeometryDTO geometry;
        private PropertiesDTO properties;
    }

    @NoArgsConstructor
    @AllArgsConstructor
    @Getter
    @Setter
    public class GeometryDTO {
        private String type;
        private Object coordinates;
    }

    @NoArgsConstructor
    @AllArgsConstructor
    @Getter
    @Setter
    public class PropertiesDTO {
        private int index;
        private int pointIndex;
        private String name;
        private String guidePointName;
        private String description;
        private String direction;
        private String intersectionName;
        private String nearPoiName;
        private String nearPoiX;
        private String nearPoiY;
        private String crossName;
        private int turnType;
        private String pointType;
    }
}