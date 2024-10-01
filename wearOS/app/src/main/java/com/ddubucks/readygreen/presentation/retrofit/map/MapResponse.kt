package com.ddubucks.readygreen.presentation.retrofit.map

data class MapResponse(
    val blinkerDTOs: List<BlinkerDTO>
)

data class BlinkerDTO(
    val id: Int,
    val lastAccessTime: String,
    val greenDuration: Int,
    val redDuration: Int,
    var currentState: String,
    var remainingTime: Int,
    val latitude: Double,
    val longitude: Double
)

data class LastAccessTime(
    val hour: Int,
    val minute: Int,
    val second: Int,
    val nano: Int
)
