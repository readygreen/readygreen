package com.ddubucks.readygreen.presentation.retrofit.navigation

data class NavigationState(
    val isNavigating: Boolean = false,
    val destinationName: String? = null,
    val currentDescription: String? = null,
    val nextDirection: Int? = null,
    val remainingDistance: Double? = null,
    val startTime: String? = null,
    val totalDistance: Double? = null
)

