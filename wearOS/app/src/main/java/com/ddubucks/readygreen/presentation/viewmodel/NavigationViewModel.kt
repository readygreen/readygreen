package com.ddubucks.readygreen.presentation.viewmodel

import android.content.Context
import android.location.Location
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.retrofit.navigation.*
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.google.android.gms.location.Priority
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class NavigationViewModel : ViewModel() {

    private val _navigationState = MutableStateFlow(NavigationState())
    val navigationState: StateFlow<NavigationState> = _navigationState
    private var locationService: LocationService? = null
    private var route: List<Feature>? = null

    // 네비게이션 시작
    fun startNavigation(context: Context, lat: Double, lng: Double, name: String) {
        locationService = LocationService(context)
        _navigationState.value = _navigationState.value.copy(destinationName = name)

        // 위치 권한 확인
        if (locationService?.hasLocationPermission() == true) {
            locationService?.getLastLocation { location ->
                if (location != null) {
                    Log.d("NavigationViewModel", "Current Location: ${location.latitude}, ${location.longitude}")
                    initiateNavigation(location.latitude, location.longitude, lat, lng, name)
                } else {
                    Log.d("NavigationViewModel", "Failed to get current location")
                    _navigationState.value = NavigationState(isNavigating = false)
                }
            }
        } else {
            Log.d("NavigationViewModel", "Location permission not granted")
            // 권한 요청은 MainActivity에서 처리하므로 여기는 필요 없음
            // 여기서는 권한 요청을 하지 않습니다.
        }
    }

    // 길안내 시작 요청
    private fun initiateNavigation(curLat: Double, curLng: Double, lat: Double, lng: Double, name: String) {
        val navigationApi = RestClient.createService(NavigationApi::class.java)
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

    // 길안내 시작 후 응답 처리
    private fun handleNavigationResponse(response: Response<NavigationResponse>) {
        if (response.isSuccessful) {
            response.body()?.let { navigationResponse ->
                Log.d("NavigationViewModel", "Received route data: ${navigationResponse.routeDTO.features}")
                route = navigationResponse.routeDTO.features

                // 네비게이션 활성화 시 위치 업데이트 빈도 및 정확도 조정
                locationService?.adjustLocationRequest(
                    priority = Priority.PRIORITY_HIGH_ACCURACY,
                    interval = 5000
                )

                locationService?.startLocationUpdates { location -> updateNavigation(location) }

                _navigationState.value = _navigationState.value.copy(
                    isNavigating = true,
                    destinationName = _navigationState.value.destinationName ?: "Green Browne",
                    remainingDistance = navigationResponse.distance,
                    startTime = navigationResponse.time
                )
            }
        } else {
            Log.d("NavigationViewModel", "Failed to parse route data")
            _navigationState.value = NavigationState(isNavigating = false)
        }
    }

    // 위치가 업데이트될 때마다 경로 갱신
    private fun updateNavigation(currentLocation: Location) {
        route?.let { routeFeatures ->
            val currentLat = currentLocation.latitude
            val currentLng = currentLocation.longitude

            Log.d("NavigationViewModel", "Updating navigation, current location: $currentLat, $currentLng")

            // 경로에 포함된 각 Feature에 대해 거리 계산 및 방향 업데이트
            routeFeatures.forEach { feature ->
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
                            val firstPoint = coordinates[0]
                            calculateDistance(currentLat, currentLng, firstPoint[1], firstPoint[0])
                        } else null
                    }
                    else -> null
                }

                if (distance != null && distance < 5) {
                    // 특정 지점에 5미터 이내로 접근했을 때 상태 업데이트
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
            // 최종 목적지에 도착시 네비게이션 완료
            if (hasReachedDestination(routeFeatures.last(), currentLat, currentLng)) {
                Log.d("NavigationViewModel", "Reached destination")
                finishNavigation()
            }
        }
    }

    // 도착 여부를 확인
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
                    val lastPoint = coordinates.last()
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

        // 목적지와 현재 위치 사이 거리 계산
        val distance = calculateDistance(currentLat, currentLng, destinationLat, destinationLng)
        return distance < 5
    }

    // 네비게이션 완료
    fun finishNavigation() {
        val currentState = navigationState.value

        val request = NavigationfinishRequest(
            distance = currentState.remainingDistance ?: 0.0,
            startTime = currentState.startTime ?: "",
            watch = true
        )

        val navigationApi = RestClient.createService(NavigationApi::class.java)
        navigationApi.finishNavigation(request).enqueue(object : Callback<Void> {
            override fun onResponse(call: Call<Void>, response: Response<Void>) {
                if (response.isSuccessful) {
                    Log.d("NavigationViewModel", "길안내 완료 성공")

                    _navigationState.value = _navigationState.value.copy(
                        isNavigating = false,
                        destinationName = null,
                        currentDescription = null,
                        nextDirection = null
                    )

                    locationService?.stopLocationUpdates()
                } else {
                    Log.d("NavigationViewModel", "길안내 완료 실패: ${response.errorBody()?.string()}")
                }
            }

            override fun onFailure(call: Call<Void>, t: Throwable) {
                Log.d("NavigationViewModel", "길안내 완료 실패: ${t.message}")
            }
        })
    }

    // 네비게이션을 중단
    fun stopNavigation() {
        val navigationApi = RestClient.createService(NavigationApi::class.java)

        viewModelScope.launch {
            navigationApi.stopNavigation(isWatch = true).enqueue(object : Callback<Void> {
                override fun onResponse(call: Call<Void>, response: Response<Void>) {
                    if (response.isSuccessful) {
                        Log.d("NavigationViewModel", "길안내 중단 성공")

                        _navigationState.value = _navigationState.value.copy(
                            isNavigating = false,
                            destinationName = null,
                            currentDescription = null,
                            nextDirection = null
                        )
                        locationService?.stopLocationUpdates()

                        Log.d("NavigationViewModel", "길안내 중단 상태반영 완료. 길안내 상태: ${_navigationState.value.isNavigating}")
                    } else {
                        Log.d("NavigationViewModel", "길안내 실패: ${response.errorBody()?.string()}")
                    }
                }

                override fun onFailure(call: Call<Void>, t: Throwable) {
                    Log.d("NavigationViewModel", "Navigation stop request failed: ${t.message}")
                }
            })
        }
    }

    // 네비게이션 체크
    fun checkNavigation() {
        val navigationApi = RestClient.createService(NavigationApi::class.java)

        viewModelScope.launch {
            try {
                val response = navigationApi.checkNavigation()
                response.enqueue(object : Callback<Void> {
                    override fun onResponse(call: Call<Void>, response: Response<Void>) {
                        when (response.code()) {
                            200 -> {
                                Log.d("NavigationViewModel", "길안내 중입니다.")
                                getNavigation()
                            }
                            204 -> {
                                Log.d("NavigationViewModel", "길안내 중이 아닙니다.")
                            }
                            else -> {
                                Log.d("NavigationViewModel", "길안내 상태 확인 실패: ${response.code()}")
                            }
                        }
                    }

                    override fun onFailure(call: Call<Void>, t: Throwable) {
                        Log.e("NavigationViewModel", "길안내 상태 확인 중 오류 발생: ${t.message}")
                    }
                })
            } catch (e: Exception) {
                Log.e("NavigationViewModel", "요청 중 오류 발생: ${e.message}")
            }
        }
    }

    // TODO fcm 연결
    // 네이게이션 정보 불러오기
    fun getNavigation() {
        val navigationApi = RestClient.createService(NavigationApi::class.java)

        viewModelScope.launch {
            try {
                val response = navigationApi.getNavigation()
                response.enqueue(object : Callback<NavigationResponse> {
                    override fun onResponse(call: Call<NavigationResponse>, response: Response<NavigationResponse>) {
                        if (response.isSuccessful) {
                            Log.d("NavigationViewModel", "Navigation data retrieved successfully: $response")
                            handleNavigationResponse(response)
                        } else {
                            Log.d("NavigationViewModel", "길안내 정보 불러오기 실패: ${response.errorBody()?.string()}")
                        }
                    }

                    override fun onFailure(call: Call<NavigationResponse>, t: Throwable) {
                        Log.e("NavigationViewModel", "길안내 정보 불러오기 실패: ${t.message}")
                    }
                })
            } catch (e: Exception) {
                Log.e("NavigationViewModel", "길안내 정보 불러오기 실패: ${e.message}")
            }
        }
    }

    // 두 좌표 사이의 거리를 계산
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
