package com.ddubucks.readygreen.presentation.retrofit.navigation

data class NavigationState(
    val isNavigating: Boolean = false,
    val destinationName: String? = null,
    val destinationLat: Double? = null,
    val destinationLng: Double? = null
)