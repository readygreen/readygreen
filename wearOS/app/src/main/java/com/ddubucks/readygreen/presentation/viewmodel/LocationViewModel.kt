package com.ddubucks.readygreen.presentation.viewmodel

import android.Manifest
import android.app.Application
import android.content.pm.PackageManager
import android.location.Location
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.core.network.LocationService
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class LocationViewModel(application: Application) : AndroidViewModel(application) {

    private val locationService = LocationService(application)

    val locationFlow: StateFlow<Location?> = locationService.locationFlow

    fun startLocationUpdates() {
        viewModelScope.launch {
            if (hasLocationPermission()) {
                locationService.requestLocationUpdates()
            } else {
                // 권한이 없을 때 권한 요청을 처리하는 코드 필요
            }
        }
    }

    // 위치 권한을 확인
    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            getApplication(),
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }
}
