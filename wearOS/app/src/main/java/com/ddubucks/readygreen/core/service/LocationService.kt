package com.ddubucks.readygreen.core.service

import android.location.Location
import android.util.Log
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
                    } ?: Log.d("LocationService", "최근 위치를 찾을 수 없습니다.")
                }
        } catch (e: SecurityException) {
            Log.e("LocationService", "위치 권한이 없습니다.", e)
        }
    }
}