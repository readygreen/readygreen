package com.ddubucks.readygreen.core.service

import android.location.Location
import com.google.android.gms.location.FusedLocationProviderClient

class LocationService {

    fun getLastLocation(
        fusedLocationClient: FusedLocationProviderClient,
        onLocationReceived: (Double, Double) -> Unit
    ) {
        try {
            fusedLocationClient.lastLocation
                .addOnSuccessListener { location: Location? ->
                    location?.let {
                        onLocationReceived(it.latitude, it.longitude)
                    }
                }
        } catch (e: SecurityException) {
            // 권한 예외 처리
        }
    }
}