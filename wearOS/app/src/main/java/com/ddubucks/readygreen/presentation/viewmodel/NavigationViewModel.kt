package com.ddubucks.readygreen.presentation.viewmodel

import android.content.Context
import android.location.Location
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

    // 길안내 상태와 경로 정보
    private val _navigationState = MutableStateFlow(NavigationState())
    val navigationState: StateFlow<NavigationState> = _navigationState

    private var locationService: LocationService? = null
    private var route: List<Feature>? = null

    // 길안내 시작 함수
    fun startNavigation(context: Context, lat: Double, lng: Double, name: String) {

        locationService = LocationService(context)

        // 마지막 위치 가져오기
        locationService?.getLastLocation { location ->
            location?.let {
                val curLat = it.latitude
                val curLng = it.longitude

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

                viewModelScope.launch {
                    navigationApi.startNavigation(navigationRequest).enqueue(object : Callback<NavigationResponse> {
                        override fun onResponse(call: Call<NavigationResponse>, response: Response<NavigationResponse>) {
                            if (response.isSuccessful) {
                                response.body()?.let { navigationResponse ->
                                    // 경로 데이터를 저장
                                    route = navigationResponse.routeDTO.features

                                    // 실시간 위치 추적 시작
                                    locationService?.startLocationUpdates { location ->
                                        updateNavigation(location)
                                    }

                                    // 길안내 시작 상태로 업데이트
                                    _navigationState.value = _navigationState.value.copy(isNavigating = true)
                                }
                            } else {
                                // API 요청이 실패할 경우 처리 (로그 남기기 등)
                                _navigationState.value = NavigationState(isNavigating = false)
                            }
                        }

                        override fun onFailure(call: Call<NavigationResponse>, t: Throwable) {
                            // 요청 실패 시 로그를 남기거나 오류 처리
                            _navigationState.value = NavigationState(isNavigating = false)
                        }
                    })
                }
            } ?: run {
                // 위치를 가져올 수 없는 경우 처리
                _navigationState.value = NavigationState(isNavigating = false)
            }
        }
    }

    // 실시간 위치와 경로를 비교하여 안내 업데이트
    private fun updateNavigation(currentLocation: Location) {
        route?.let { routeFeatures ->
            val currentLat = currentLocation.latitude
            val currentLng = currentLocation.longitude

            for (feature in routeFeatures) {
                val nextLat = feature.geometry.coordinates[1]
                val nextLng = feature.geometry.coordinates[0]

                val distance = calculateDistance(currentLat, currentLng, nextLat, nextLng)

                // 사용자가 경로 지점에 가까워지면 안내 업데이트
                if (distance < 50) { // 예를 들어, 50미터 이내
                    _navigationState.value = NavigationState(
                        isNavigating = true,
                        destinationName = feature.properties.name,
                        currentDescription = feature.properties.description,
                        nextDirection = feature.properties.turnType,
                        remainingDistance = distance
                    )
                    break
                }
            }

            // 목적지 도착 시 안내 중단
            if (routeFeatures.last().geometry.coordinates[1] == currentLat &&
                routeFeatures.last().geometry.coordinates[0] == currentLng) {
                stopNavigation()
            }
        }
    }

    // 길안내 중단 함수
    fun stopNavigation() {
        _navigationState.value = NavigationState(isNavigating = false)
        locationService?.stopLocationUpdates()
        locationService = null
    }

    // 두 좌표 간의 거리를 계산하는 함수
    private fun calculateDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double): Double {
        val location1 = Location("").apply {
            latitude = lat1
            longitude = lng1
        }
        val location2 = Location("").apply {
            latitude = lat2
            longitude = lng2
        }
        return location1.distanceTo(location2).toDouble() // 미터 단위 거리 반환
    }

    // 좌표 정리
    private fun roundToSix(value: Double): Double {
        return String.format("%.6f", value).toDouble()
    }
}
