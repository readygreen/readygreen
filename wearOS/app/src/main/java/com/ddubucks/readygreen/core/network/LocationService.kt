package com.ddubucks.readygreen.core.network

import android.annotation.SuppressLint
import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import androidx.core.content.ContextCompat
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class LocationService(private val context: Context) {

    private val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    private val _locationFlow = MutableStateFlow<Location?>(null)
    val locationFlow: StateFlow<Location?> = _locationFlow

    @SuppressLint("MissingPermission")
    fun requestLocationUpdates() {
        // 위치 업데이트를 수신
        locationManager.requestLocationUpdates(
            LocationManager.GPS_PROVIDER,
            1000L, // 업데이트 주기 (밀리초)
            10f, // 거리 차이 (미터)
            object : LocationListener {
                override fun onLocationChanged(location: Location) {
                    _locationFlow.value = location
                }

                override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
                override fun onProviderEnabled(provider: String) {}
                override fun onProviderDisabled(provider: String) {}
            }
        )
    }
}
