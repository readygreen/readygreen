package com.ddubucks.readygreen.presentation.retrofit.navigation

import com.ddubucks.readygreen.presentation.retrofit.map.BlinkerDTO
import kotlin.String
import kotlin.Int
import kotlin.collections.List


data class NavigationResponse(
    val routeDTO: RouteDTO,
    val blinkerDTOs: List<BlinkerDTO>,
    val distance: Double,
    val time: String
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
    val coordinates: Any
) {
    fun getCoordinatesAsDoubleArray(): List<Double>? {
        return if (type == "Point") {
            coordinates as? List<Double>
        } else {
            null
        }
    }

    fun getCoordinatesAsLineString(): List<List<Double>>? {
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
