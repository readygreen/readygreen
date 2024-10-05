package com.ddubucks.readygreen.core.service

import android.Manifest
import android.app.Activity
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.*

class LocationService(private val context: Context) {

    companion object {
        // 위치 권한 요청 시 사용하는 코드
        const val REQUEST_LOCATION_PERMISSION_CODE = 1001
    }

    // 위치 업데이트 및 마지막 위치 관리
    private val fusedLocationClient: FusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(context)

    // 위치 요청: 정확도와 업데이트 간격 설정
    private var locationRequest: LocationRequest = LocationRequest.Builder(
        Priority.PRIORITY_BALANCED_POWER_ACCURACY, // 위치 업데이트 우선순위
        10000 // 위치 업데이트 간격 (밀리초)
    ).setMinUpdateIntervalMillis(5000) // 최소 업데이트 간격 설정
        .build()

    private var locationCallback: LocationCallback? = null
    private var previousLocation: Location? = null

    // 위치 권한이 있는지 확인
    fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    // 마지막 위치를 가져오는 함수 (권한이 있을 때만)
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

    // 위치 업데이트를 시작하는 함수
    @SuppressLint("MissingPermission")
    fun startLocationUpdates(onLocationUpdated: (Location) -> Unit) {
        if (hasLocationPermission()) {
            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    locationResult.lastLocation?.let { location ->
                        // 위치가 이전 위치보다 10m 이상 차이 날 때만 업데이트 호출
                        val lastLocation = previousLocation
                        if (lastLocation == null || location.distanceTo(lastLocation) > 10) {
                            previousLocation = location
                            onLocationUpdated(location)
                        }
                    }
                }
            }
            // 위치 업데이트 요청
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback!!, Looper.getMainLooper())
        }
    }

    // 위치 업데이트를 중단하는 함수
    fun stopLocationUpdates() {
        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it)
        }
    }

    // 위치 요청 설정을 조정하는 함수 (우선순위와 간격)
    fun adjustLocationRequest(priority: Int, interval: Long) {
        locationRequest = LocationRequest.Builder(
            priority,
            interval
        ).setMinUpdateIntervalMillis(5000)
            .build()
    }

    // 위치 권한을 요청하는 함수
    fun requestLocationPermission(activity: Activity) {
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
            REQUEST_LOCATION_PERMISSION_CODE
        )
    }
}
