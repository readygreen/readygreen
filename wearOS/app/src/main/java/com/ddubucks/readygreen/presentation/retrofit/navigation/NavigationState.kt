package com.ddubucks.readygreen.presentation.retrofit.navigation

data class NavigationState(
    val isNavigating: Boolean = false,
    val destinationName: String? = null,
    val currentDescription: String? = null,
    val nextDirection: Int? = null,
    val Distance: Double? = null,
    val startTime: String? = null,
    val totalDistance: Double? = null,
    val trafficLightColor: String? = null,
    val trafficLightRemainingTime: Int? = null,
    val currentBlinkerInfo: BlinkerDTO? = null
)