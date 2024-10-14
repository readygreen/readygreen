package com.ddubucks.readygreen.dto;

public class LocationRequestPlaceDTO {
    private double latitude;
    private double longitude;

    // Getter 및 Setter
    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }
}
