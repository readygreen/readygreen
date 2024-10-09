package com.ddubucks.readygreen.presentation.retrofit.navigation

data class NavigationState(
    val isNavigating: Boolean = false,
    val destinationName: String? = null,  // 목적지이름
    val currentDescription: String? = null, // 현재 안내
    val nextDirection: Int? = null,
    val Distance: Double? = null,
    val startTime: String? = null,
    val totalDistance: Double? = null,
    val trafficLightColor: String? = null, // 신호등 색깔
    val trafficLightRemainingTime: Int? = null, // 신호등 남은 시간
    val currentBlinkerInfo: BlinkerDTO? = null // 신호등 정보를 추가
)