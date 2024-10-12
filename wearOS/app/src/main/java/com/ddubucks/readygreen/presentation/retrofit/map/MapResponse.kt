package com.ddubucks.readygreen.presentation.retrofit.map

data class MapResponse(
    val blinkerDTOs: List<BlinkerDTO>
)

data class BlinkerDTO(
    val id: Int,
    val startTime: String,
    val greenDuration: Int,
    val redDuration: Int,
    var currentState: String,
    var remainingTime: Int,
    val latitude: Double,
    val longitude: Double
)