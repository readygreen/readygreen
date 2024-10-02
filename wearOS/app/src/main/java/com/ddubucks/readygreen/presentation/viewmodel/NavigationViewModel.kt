package com.ddubucks.readygreen.presentation.viewmodel

import android.app.Activity
import android.content.Context
import android.location.Location
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.retrofit.navigation.*
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class NavigationViewModel : ViewModel() {

    // 현재 네비게이션 상태
    private val _navigationState = MutableStateFlow(NavigationState())
    val navigationState: StateFlow<NavigationState> = _navigationState

    // 위치 서비스 및 경로 데이터
    private var locationService: LocationService? = null
    private var route: List<Feature>? = null

    // 네비게이 시작
    fun startNavigation(context: Context, lat: Double, lng: Double, name: String) {
        locationService = LocationService(context)

        // 네비게이션 상태에 목적지 이름을 설정
        _navigationState.value = _navigationState.value.copy(destinationName = name)

        // 위치 권한이 있는지 확인하고, 마지막 위치를 가져옴
        if (locationService?.hasLocationPermission() == true) {
            locationService?.getLastLocation { location ->
                if (location != null) {
                    // 현재 위치를 로그로 출력하고, 네비게이션을 시작
                    Log.d("NavigationViewModel", "Current Location: ${location.latitude}, ${location.longitude}")
                    initiateNavigation(context, location.latitude, location.longitude, lat, lng, name)
                } else {
                    // 위치 정보를 얻지 못하면 네비게이션을 중단
                    Log.d("NavigationViewModel", "Failed to get current location")
                    _navigationState.value = NavigationState(isNavigating = false)
                }
            }
        } else {
            // 위치 권한이 없을 경우, 권한 요청
            Log.d("NavigationViewModel", "Location permission not granted")
            locationService?.requestLocationPermission(context as Activity)
        }
    }

    // 네비게이션 시작 api 요청
    private fun initiateNavigation(context: Context, curLat: Double, curLng: Double, lat: Double, lng: Double, name: String) {
        val navigationApi = RestClient.createService(NavigationApi::class.java, context)
        val navigationRequest = NavigationRequest(
            startX = roundToSix(curLng),
            startY = roundToSix(curLat),
            endX = roundToSix(lng),
            endY = roundToSix(lat),
            startName = "현재 위치",
            endName = name,
            watch = true
        )

        Log.d("NavigationViewModel", "Sending navigation request: $navigationRequest")

        viewModelScope.launch {
            navigationApi.startNavigation(navigationRequest).enqueue(object : Callback<NavigationResponse> {
                override fun onResponse(call: Call<NavigationResponse>, response: Response<NavigationResponse>) {
                    if (response.isSuccessful) {
                        Log.d("NavigationViewModel", "Navigation API successful")
                        handleNavigationResponse(response)
                    } else {
                        Log.d("NavigationViewModel", "Navigation API failed: ${response.errorBody()?.string()}")
                        _navigationState.value = NavigationState(isNavigating = false)
                    }
                }

                override fun onFailure(call: Call<NavigationResponse>, t: Throwable) {
                    Log.d("NavigationViewModel", "Navigation API request failed: ${t.message}")
                    _navigationState.value = NavigationState(isNavigating = false)
                }
            })
        }
    }

    // 네비게이션 경로 데이터 처리
    private fun handleNavigationResponse(response: Response<NavigationResponse>) {
        if (response.isSuccessful) {
            response.body()?.let { navigationResponse ->
                // 서버에서 받은 경로 데이터를 로그로 출력하고, 위치 업데이트를 시작
                Log.d("NavigationViewModel", "Received route data: ${navigationResponse.routeDTO.features}")
                route = navigationResponse.routeDTO.features
                locationService?.startLocationUpdates { location -> updateNavigation(location) }
                // 네비게이션 상태를 업데이트
                _navigationState.value = _navigationState.value.copy(
                    isNavigating = true,
                    destinationName = _navigationState.value.destinationName // 목적지 이름 유지
                )
            }
        } else {
            Log.d("NavigationViewModel", "Failed to parse route data")
            _navigationState.value = NavigationState(isNavigating = false)
        }
    }

    // 현재 위치와 경로 데이터를 비교하여 네비게이션 상태를 업데이트
    private fun updateNavigation(currentLocation: Location) {
        route?.let { routeFeatures ->
            val currentLat = currentLocation.latitude
            val currentLng = currentLocation.longitude

            Log.d("NavigationViewModel", "Updating navigation, current location: $currentLat, $currentLng")

            routeFeatures.forEach { feature ->
                // 현재 위치와 경로상의 포인트 또는 라인의 거리를 계산
                val distance = when (feature.geometry.type) {
                    "Point" -> {
                        val coordinates = feature.geometry.getCoordinatesAsDoubleArray()
                        if (coordinates != null) {
                            calculateDistance(currentLat, currentLng, coordinates[1], coordinates[0])
                        } else null
                    }
                    "LineString" -> {
                        val coordinates = feature.geometry.getCoordinatesAsLineString()
                        if (coordinates != null && coordinates.isNotEmpty()) {
                            val firstPoint = coordinates[0] // 첫 번째 좌표로 거리 계산
                            calculateDistance(currentLat, currentLng, firstPoint[1], firstPoint[0])
                        } else null
                    }
                    else -> null
                }

                // 만약 거리가 50미터 이내면, 네비게이션 상태를 업데이트하고 반환
                if (distance != null && distance < 50) {
                    Log.d("NavigationViewModel", "Within 50 meters of feature: ${feature.properties.name}")
                    _navigationState.value = _navigationState.value.copy(
                        isNavigating = true,
                        destinationName = _navigationState.value.destinationName,
                        currentDescription = feature.properties.description,
                        nextDirection = feature.properties.turnType,
                        remainingDistance = distance
                    )
                    return
                }
            }

            // 최종 목적지에 도착하면 네비게이션 도착 완료 요청
            if (hasReachedDestination(routeFeatures.last(), currentLat, currentLng)) {
                Log.d("NavigationViewModel", "Reached destination")
                finishNavigation()
            }
        }
    }

    // 현재 위치와 최종 목적지 사이의 거리를 계산하여 도착 여부를 확인
    private fun hasReachedDestination(feature: Feature, currentLat: Double, currentLng: Double): Boolean {
        val destinationLat: Double
        val destinationLng: Double

        when (feature.geometry.type) {
            "Point" -> {
                val coordinates = feature.geometry.getCoordinatesAsDoubleArray()
                if (coordinates != null && coordinates.size >= 2) {
                    destinationLat = coordinates[1]
                    destinationLng = coordinates[0]
                } else {
                    Log.d("NavigationViewModel", "Invalid Point coordinates")
                    return false
                }
            }
            "LineString" -> {
                val coordinates = feature.geometry.getCoordinatesAsLineString()
                if (coordinates != null && coordinates.isNotEmpty()) {
                    val lastPoint = coordinates.last() // 마지막 좌표 사용
                    destinationLat = lastPoint[1]
                    destinationLng = lastPoint[0]
                } else {
                    Log.d("NavigationViewModel", "Invalid LineString coordinates")
                    return false
                }
            }
            else -> {
                Log.d("NavigationViewModel", "Unsupported geometry type: ${feature.geometry.type}")
                return false
            }
        }

        // 목적지와 현재 위치 사이의 거리를 계산하고, 50미터 이내면 도착으로 간주
        val distance = calculateDistance(currentLat, currentLng, destinationLat, destinationLng)
        return distance < 50
    }

    // 네비게이션 도착완료
    fun finishNavigation() {
        Log.d("NavigationViewModel", "Stopping navigation")
        _navigationState.value = NavigationState(isNavigating = false)
        locationService?.stopLocationUpdates()
        locationService = null
        // TODO map/guide post : 길안내 완료
    }

    // 네비게이션 중단
    fun stopNavigation() {
        // TODO map/guide delete : 길안내 중단
    }

    // 네비게이션 요청 불러오기
    fun getNavigation() {
        // TODO map/guide get : 길안내중이라는 알림 받았을때 요청 불러오기
    }

    // 두 좌표 사이의 거리를 계산하는 함수
    private fun calculateDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double): Double {
        val location1 = Location("").apply { latitude = lat1; longitude = lng1 }
        val location2 = Location("").apply { latitude = lat2; longitude = lng2 }
        return location1.distanceTo(location2).toDouble()
    }

    // 좌표 반올림
    private fun roundToSix(value: Double): Double {
        return String.format("%.6f", value).toDouble()
    }
}
