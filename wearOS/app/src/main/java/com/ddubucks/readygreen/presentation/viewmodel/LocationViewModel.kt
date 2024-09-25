package com.ddubucks.readygreen.presentation.viewmodel

import android.app.Application
import android.location.Location
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.core.service.LocationService
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class LocationViewModel(application: Application) : AndroidViewModel(application) {

    private val locationService = LocationService(application)
    val locationFlow: StateFlow<Location?> = locationService.locationFlow

    // 위치 업데이트 시작
    fun startLocationUpdates() {
        viewModelScope.launch {
            if (hasLocationPermission()) {
                locationService.requestLocationUpdates() // 권한이 있을 때 위치 업데이트 요청
            } else {
                // 권한 요청 로직을 처리하는 부분 필요
            }
        }
    }

    // 위치 권한이 있는지 확인하는 함수
    private fun hasLocationPermission(): Boolean {
        return androidx.core.content.ContextCompat.checkSelfPermission(
            getApplication(),
            android.Manifest.permission.ACCESS_FINE_LOCATION
        ) == android.content.pm.PackageManager.PERMISSION_GRANTED
    }
}