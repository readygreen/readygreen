package com.ddubucks.readygreen.presentation.retrofit.bookmark

data class BookmarkResponse(
    val id: Int,
    val name: String,
    val destinationName: String,
    val latitude: Double,
    val longitude: Double,
    val alertTime: AlertTime
)

// 알림시간
data class AlertTime(
    val hour: Int,
    val minute: Int,
    val second: Int,
    val nano: Int
)
