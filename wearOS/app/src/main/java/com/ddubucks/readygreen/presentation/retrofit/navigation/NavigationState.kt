package com.ddubucks.readygreen.presentation.retrofit.navigation

data class NavigationState(
    val isNavigating: Boolean = false,              // 현재 네비게이션 중인지 여부
    val destinationName: String? = null,           // 목적지 이름
    val currentDescription: String? = null,         // 현재 길안내 설명
    val nextDirection: Int? = null,                 // 다음 이동 방향
    val remainingDistance: Double? = null,          // 남은 거리
    val startTime: String? = null,                  // 시작 시간
    val totalDistance: Double? = null,              // 총 거리
    val trafficLightColor: String? = null,          // 다음 신호등 색깔
    val trafficLightRemainingTime: Int? = null      // 다음 신호등 남은 시간 (초)
)
