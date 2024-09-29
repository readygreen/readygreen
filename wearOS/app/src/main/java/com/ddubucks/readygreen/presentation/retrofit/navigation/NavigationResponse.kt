package com.ddubucks.readygreen.presentation.retrofit.navigation


data class RouteDTO(
    val type: String,
    val features: List<Feature>
)

data class Feature(
    val type: String,
    val geometry: Geometry,
    val properties: Properties
)

data class Geometry(
    val type: String,
    val coordinates: List<Double>
)

data class Properties(
    val index: Int,
    val pointIndex: Int,
    val name: String,
    val guidePointName: String,
    val description: String,
    val direction: String,
    val intersectionName: String,
    val nearPoiName: String,
    val nearPoiX: String,
    val nearPoiY: String,
    val crossName: String,
    val turnType: Int,
    val pointType: String
)


data class BlinkerDTO(
    val id: Int,
    val lastAccessTime: LastAccessTime,
    val greenDuration: Int,
    val redDuration: Int,
    val currentState: String,
    val remainingTime: Int,
    val latitude: Double,
    val longitude: Double
)

data class LastAccessTime(
    val hour: Int,
    val minute: Int,
    val second: Int,
    val nano: Int
)


data class NavigationResponse(
    val routeDTO: RouteDTO,
    val blinkerDTOs: List<BlinkerDTO>
)