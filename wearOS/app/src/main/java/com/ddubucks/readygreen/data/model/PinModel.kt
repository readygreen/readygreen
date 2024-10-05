package com.ddubucks.readygreen.data.model

data class PinModel(
    val id: Int,  // 신호등의 고유 ID
    val lastAccessTime: String,  // 마지막 신호등 상태 변경 시간 (String으로 변환)
    val greenDuration: Int,  // 초록불 지속 시간
    val redDuration: Int,  // 빨간불 지속 시간
    val currentState: String,  // 현재 상태 (빨간불 또는 초록불)
    val remainingTime: Int,  // 현재 남은 시간
    val latitude: Double,  // 신호등의 위도
    val longitude: Double  // 신호등의 경도
)
