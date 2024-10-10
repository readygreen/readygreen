package com.ddubucks.readygreen.core.service

import android.Manifest
import android.app.Activity
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.*

class LocationService(private val context: Context) {

    companion object {
        const val REQUEST_LOCATION_PERMISSION_CODE = 1001
    }

    // 위치 업데이트 및 마지막 위치 관리
    private val fusedLocationClient: FusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(context)

    // 위치 요청: 정확도와 업데이트 간격 설정
    private var locationRequest: LocationRequest = LocationRequest.Builder(
        Priority.PRIORITY_BALANCED_POWER_ACCURACY,
        10000
    ).setMinUpdateIntervalMillis(1000)
        .build()

    private var locationCallback: LocationCallback? = null
    private var previousLocation: Location? = null

    // 위치 권한 확인
    fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    // 마지막 위치
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

    // 위치 업데이트
    @SuppressLint("MissingPermission")
    fun startLocationUpdates(onLocationUpdated: (Location) -> Unit) {
        // 위치 권한 확인 로그
        Log.d("LocationService", hasLocationPermission().toString())
        if (hasLocationPermission()) {
            Log.d("LocationService", "위치 권한 있음. 위치 업데이트 요청 시작")

            // LocationCallback 설정
            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    // 위치 업데이트 결과 수신
                    locationResult.lastLocation?.let { location ->
                        // 이전 위치와 현재 위치 로그
                        val lastLocation = previousLocation
                        if (lastLocation == null) {
                            Log.d("LocationService", "이전 위치 없음. 현재 위치: $location")
                        } else {
                            Log.d("LocationService", "이전 위치: $lastLocation, 현재 위치: $location, 거리: ${location.distanceTo(lastLocation)}m")
                        }

                        // 위치가 이전 위치보다 10m 이상 차이 날 때만 업데이트 호출
                        if (lastLocation == null || location.distanceTo(lastLocation) > 10) {
                            previousLocation = location
                            Log.d("LocationService", "위치 업데이트 호출: $location")
                            onLocationUpdated(location)
                        } else {
                            Log.d("LocationService", "위치 변화가 10m 미만으로 업데이트 호출하지 않음")
                        }
                    } ?: run {
                        Log.d("LocationService", "위치 정보를 수신하지 못함 (lastLocation null)")
                    }
                }
            }

            // 위치 업데이트 요청
            Log.d("LocationService", "FusedLocationClient에 위치 업데이트 요청")
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback!!, Looper.getMainLooper())
        } else {
            // 권한 없음 로그
            Log.d("LocationService", "위치 권한 없음. 위치 업데이트 요청 불가")
        }
    }


    // 위치 업데이트 중단
    fun stopLocationUpdates() {
        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it)
        }
    }

    // 위치 요청 설정을 조정
    fun adjustLocationRequest(priority: Int, interval: Long) {
        locationRequest = LocationRequest.Builder(
            priority,
            interval
        ).setMinUpdateIntervalMillis(1000)
            .build()
    }

    // 위치 권한 요청
    fun requestLocationPermission(activity: Activity) {
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
            REQUEST_LOCATION_PERMISSION_CODE
        )
    }
}