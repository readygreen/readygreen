package com.ddubucks.readygreen.presentation.retrofit.navigation

data class NavigationRequest(
    val startX: Double,
    val startY: Double,
    val endX: Double,
    val endY: Double,
    val startName: String,
    val endName: String,
    val watch: Boolean
)

data class NavigationfinishRequest(
    val distance: Double,
    val startupTime: String,
    val watch: Boolean
)
