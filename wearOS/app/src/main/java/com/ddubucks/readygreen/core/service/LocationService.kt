package com.ddubucks.readygreen.core.service

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import androidx.core.content.ContextCompat
import com.google.android.gms.location.*

class LocationService(private val context: Context) {

    private val fusedLocationClient: FusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(context)

    // 위치 업데이트 요청 설정
    private var locationRequest: LocationRequest = LocationRequest.Builder(
        Priority.PRIORITY_BALANCED_POWER_ACCURACY,
        10000
    ).setMinUpdateIntervalMillis(5000)
        .build()

    private var locationCallback: LocationCallback? = null

    // 위치 권한 체크
    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    // 마지막 위치 가져오기
    @SuppressLint("MissingPermission")
    fun getLastLocation(onLocationReceived: (Location?) -> Unit) {
        if (hasLocationPermission()) {
            fusedLocationClient.lastLocation
                .addOnSuccessListener { location: Location? ->
                    onLocationReceived(location)
                }
                .addOnFailureListener {
                    onLocationReceived(null)
                }
        } else {
            onLocationReceived(null)
        }
    }

    // 지속적인 위치 추적 시작
    @SuppressLint("MissingPermission")
    fun startLocationUpdates(onLocationUpdated: (Location) -> Unit) {
        if (hasLocationPermission()) {
            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    locationResult.lastLocation?.let { location ->
                        onLocationUpdated(location)
                    }
                }
            }
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback!!, Looper.getMainLooper())
        }
    }

    // 위치 업데이트 중지
    fun stopLocationUpdates() {
        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it)
        }
    }

    // 위치 서비스 최적화: 배터리 소모 줄이기 위해서 필요시 호출
    fun adjustLocationRequest(priority: Int, interval: Long) {
        locationRequest = LocationRequest.Builder(
            priority,
            interval
        ).setMinUpdateIntervalMillis(5000)
            .build()
    }
}
