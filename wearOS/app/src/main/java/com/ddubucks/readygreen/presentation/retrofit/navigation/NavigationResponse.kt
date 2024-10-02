package com.ddubucks.readygreen.presentation.retrofit.navigation

import com.ddubucks.readygreen.presentation.retrofit.map.BlinkerDTO
import kotlin.String
import kotlin.Int
import kotlin.collections.List


data class NavigationResponse(
    val routeDTO: RouteDTO,
    val blinkerDTOs: List<BlinkerDTO>
)

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
    val coordinates: Any // 다양한 좌표 형식을 처리할 수 있도록 Any 타입으로 선언
) {
    fun getCoordinatesAsDoubleArray(): List<Double>? {
        // Point 타입일 경우, 좌표를 double 리스트로 반환
        return if (type == "Point") {
            coordinates as? List<Double>
        } else {
            null
        }
    }

    fun getCoordinatesAsLineString(): List<List<Double>>? {
        // LineString 타입일 경우, 이중 리스트로 좌표 반환
        return if (type == "LineString") {
            coordinates as? List<List<Double>>
        } else {
            null
        }
    }
}


data class Properties(
    val description: String,
    val turnType: Int,
    val name: String
)
