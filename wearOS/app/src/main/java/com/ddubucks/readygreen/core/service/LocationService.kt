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
        const val REQUEST_LOCATION_PERMISSION_CODE = 1001 // 위치 권한 요청 코드
    }

    // Google의 FusedLocationProviderClient를 사용하여 위치 업데이트 관리
    private val fusedLocationClient: FusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(context)

    // 초기 위치 요청 설정: 배터리 효율을 위해 정확도는 적당히, 업데이트는 10초 간격
    private var locationRequest: LocationRequest = LocationRequest.Builder(
        Priority.PRIORITY_BALANCED_POWER_ACCURACY, // 중간 정도의 정확도 설정
        10000 // 10초 간격으로 위치 업데이트
    ).setMinUpdateIntervalMillis(5000) // 최소 5초 간격으로 업데이트 허용
        .build()

    // 위치 콜백과 이전 위치를 저장할 변수
    private var locationCallback: LocationCallback? = null
    private var previousLocation: Location? = null

    // 위치 권한이 있는지 확인하는 함수
    fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    // 마지막으로 저장된 위치를 가져오는 함수
    @SuppressLint("MissingPermission")
    fun getLastLocation(onLocationReceived: (Location?) -> Unit) {
        if (hasLocationPermission()) {
            // 마지막 위치 정보를 가져와서 콜백 함수로 전달
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
            // 위치 업데이트를 위한 콜백 설정
            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    locationResult.lastLocation?.let { location ->
                        // 이전 위치와 현재 위치 간의 거리 차이가 10미터 이상일 때만 업데이트
                        val lastLocation = previousLocation
                        if (lastLocation == null || location.distanceTo(lastLocation) > 10) {
                            previousLocation = location
                            onLocationUpdated(location) // 콜백으로 현재 위치 전달
                        }
                    }
                }
            }
            // 위치 업데이트 요청 시작
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback!!, Looper.getMainLooper())
        }
    }

    // 위치 업데이트를 중단하는 함수
    fun stopLocationUpdates() {
        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it) // 위치 업데이트 요청 취소
        }
    }

    // 위치 요청 설정을 조정하는 함수 (우선순위와 간격 조정)
    fun adjustLocationRequest(priority: Int, interval: Long) {
        locationRequest = LocationRequest.Builder(
            priority, // 우선순위 (정확도)
            interval  // 업데이트 간격
        ).setMinUpdateIntervalMillis(5000) // 최소 5초
            .build()

        // 위치 업데이트 요청이 진행 중일 경우 새 설정으로 업데이트
        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it)
            fusedLocationClient.requestLocationUpdates(locationRequest, it, Looper.getMainLooper())
        }
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
