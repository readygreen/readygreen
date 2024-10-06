package com.ddubucks.readygreen.presentation.viewmodel

import android.content.Context
import android.location.Location
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
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
import java.text.SimpleDateFormat
import java.util.Locale

class NavigationViewModel : ViewModel() {

    private val _navigationState = MutableStateFlow(NavigationState())
    val navigationState: StateFlow<NavigationState> = _navigationState
    private var locationService: LocationService? = null
    private var route: List<Feature>? = null
    private var blinkers: List<BlinkerDTO>? = null

    private val _navigationCommand = MutableLiveData<String>()
    val navigationCommand: LiveData<String> get() = _navigationCommand

    // 현재 위치를 저장할 변수 추가
    private var currentLocation: Location? = null

    // 네비게이션 시작
    fun startNavigation(context: Context, lat: Double, lng: Double, name: String) {
        locationService = LocationService(context)
        _navigationState.value = _navigationState.value.copy(destinationName = name)

        locationService?.getLastLocation { location ->
            if (location != null) {
                Log.d("NavigationViewModel", "현재 위치: ${location.latitude}, ${location.longitude}")
                // 현재 위치를 저장
                currentLocation = location
                initiateNavigation(location.latitude, location.longitude, lat, lng, name)
            } else {
                Log.d("NavigationViewModel", "현재 위치 불러오기 실패")
                _navigationState.value = NavigationState(isNavigating = false)
            }
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

        Log.d("NavigationViewModel", "navigation 요청 전송: $navigationRequest")

        viewModelScope.launch {
            navigationApi.startNavigation(navigationRequest).enqueue(object : Callback<NavigationResponse> {
                override fun onResponse(call: Call<NavigationResponse>, response: Response<NavigationResponse>) {
                    if (response.isSuccessful) {
                        Log.d("NavigationViewModel", "Navigation API 받기 성공")
                        handleNavigationResponse(response)
                    } else {
                        Log.d("NavigationViewModel", "Navigation API 받기 실패: ${response.errorBody()?.string()}")
                        _navigationState.value = NavigationState(isNavigating = false)
                    }
                }

                override fun onFailure(call: Call<NavigationResponse>, t: Throwable) {
                    Log.d("NavigationViewModel", "Navigation API 요청 실패: ${t.message}")
                    _navigationState.value = NavigationState(isNavigating = false)
                }
            })
        }
    }

    // 길안내 시작 후 응답 처리
    private fun handleNavigationResponse(response: Response<NavigationResponse>) {
        response.body()?.let { navigationResponse ->
            route = navigationResponse.routeDTO.features
            blinkers = navigationResponse.blinkerDTOs

            // 첫 번째 포인트 설명 업데이트
            route?.firstOrNull { it.geometry.type == "Point" }?.let { firstPoint ->
                _navigationState.value = _navigationState.value.copy(
                    currentDescription = firstPoint.properties.description ?: "안내 없음"
                )
            }

            // 위치 업데이트 빈도 설정
            locationService?.adjustLocationRequest(
                priority = Priority.PRIORITY_HIGH_ACCURACY,
                interval = 1000
            )

            // 위치 업데이트 시작
            locationService?.startLocationUpdates { location -> updateNavigation(location) }

            _navigationState.value = _navigationState.value.copy(
                isNavigating = true,
                destinationName = navigationResponse.routeDTO.features.last().properties.name ?: "알 수 없음",
                remainingDistance = navigationResponse.distance,
                startTime = navigationResponse.time
            )
        } ?: run {
            Log.d("NavigationViewModel", "경로 정보 받기 실패")
            _navigationState.value = NavigationState(isNavigating = false)
        }
    }

    // 현재 위치를 기반으로 네비게이션 업데이트
    private fun updateNavigation(currentLocation: Location) {
        this.currentLocation = currentLocation // 위치 업데이트 시 저장

        val currentLat = currentLocation.latitude
        val currentLng = currentLocation.longitude
        var closestFeature: Feature? = null
        var minDistance = Double.MAX_VALUE
        val distanceThreshold = 10.0 // 안내 변경 기준

        route?.forEach { feature ->
            when (feature.geometry.type) {
                "Point" -> {
                    // Point 처리
                    val coordinates = feature.geometry.getCoordinatesAsDoubleArray()
                    coordinates?.let {
                        val distance = calculateDistance(currentLat, currentLng, it[1], it[0])

                        // 가장 가까운 포인트 찾기
                        if (distance < minDistance) {
                            minDistance = distance
                            closestFeature = feature
                        }
                    }
                }
                "LineString" -> {
                    // LineString 처리
                    val coordinates = feature.geometry.getCoordinatesAsLineString()
                    coordinates?.let { lineCoords ->
                        val isOnLine = isPointNearLine(currentLat, currentLng, lineCoords)
                        if (isOnLine) {
                            Log.d("NavigationViewModel", "사용자가 경로 위에 있습니다.")
                        }
                    }
                }
            }
        }

        // 가장 가까운 포인트가 유연성 범위 내에 있을 때만 안내
        closestFeature?.let { feature ->
            if (minDistance < distanceThreshold) {
                Log.d("NavigationViewModel", "다음 지점에 10미터 이내로 접근: ${feature.properties.name}")
                _navigationState.value = _navigationState.value.copy(
                    currentDescription = feature.properties.description ?: "안내 없음",
                    nextDirection = feature.properties.turnType,
                    remainingDistance = minDistance
                )
            }
        }

        // 신호등 상태 업데이트
        blinkers?.let { updateTrafficLight(currentLat, currentLng, it) }

        // 목적지 도착 여부 확인
        if (hasReachedDestination(route?.lastOrNull(), currentLat, currentLng)) {
            Log.d("NavigationViewModel", "목적지에 도착했습니다!")
            finishNavigation()
        }
    }

    // 신호등 상태 업데이트 메서드
    fun updateTrafficLightState() {
        currentLocation?.let { location ->
            blinkers?.let { blinkersList ->
                // 현재 위치를 기반으로 신호등 상태 갱신
                updateTrafficLight(location.latitude, location.longitude, blinkersList)
            }
        }
    }

    // 기존 updateTrafficLight 메서드
    private fun updateTrafficLight(currentLat: Double, currentLng: Double, blinkers: List<BlinkerDTO>) {
        val nextTrafficLight = findNextTrafficLightOnRoute(currentLat, currentLng, blinkers)

        nextTrafficLight?.let { blinker ->
            val currentTimeInSeconds = System.currentTimeMillis() / 1000
            val lastAccessTimeInSeconds = convertTimeToSeconds(blinker.lastAccessTime)
            val elapsedTimeInSeconds = currentTimeInSeconds - lastAccessTimeInSeconds
            val cycleDuration = blinker.greenDuration + blinker.redDuration
            val timeInCurrentCycle = elapsedTimeInSeconds % cycleDuration

            val currentState: String
            val remainingTime: Int

            if (timeInCurrentCycle < blinker.greenDuration) {
                currentState = "GREEN"
                remainingTime = blinker.greenDuration - timeInCurrentCycle.toInt()
            } else {
                currentState = "RED"
                remainingTime = blinker.redDuration - (timeInCurrentCycle - blinker.greenDuration).toInt()
            }

            _navigationState.value = _navigationState.value.copy(
                trafficLightColor = currentState,
                trafficLightRemainingTime = remainingTime
            )
        }
    }

    // 시간을 초 단위로 변환하는 함수
    private fun convertTimeToSeconds(timeString: String): Long {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
        return try {
            val date = dateFormat.parse(timeString)
            date?.time?.div(1000) ?: 0L // 밀리초를 초로 변환
        } catch (e: Exception) {
            Log.e("NavigationViewModel", "시간 변환 오류: ${e.message}")
            0L
        }
    }


    // 경로 상에서 다음 신호등을 찾는 함수
    private fun findNextTrafficLightOnRoute(currentLat: Double, currentLng: Double, blinkers: List<BlinkerDTO>): BlinkerDTO? {
        var nextTrafficLight: BlinkerDTO? = null
        var minDistance = Double.MAX_VALUE

        route?.forEach { feature ->
            when (feature.geometry.type) {
                "LineString" -> {
                    val lineCoords = feature.geometry.getCoordinatesAsLineString()
                    lineCoords?.forEach { coord ->
                        val segmentLat = coord[1]
                        val segmentLng = coord[0]

                        blinkers.forEach { blinker ->
                            val distanceToBlinker = calculateDistance(segmentLat, segmentLng, blinker.latitude, blinker.longitude)
                            if (distanceToBlinker < 10) { // 신호등이 경로 좌표와 가까운지 확인 (10미터 이내)
                                val currentDistance = calculateDistance(currentLat, currentLng, blinker.latitude, blinker.longitude)
                                if (currentDistance > 0 && currentDistance < minDistance) {
                                    minDistance = currentDistance
                                    nextTrafficLight = blinker
                                }
                            }
                        }
                    }
                }
            }
        }
        return nextTrafficLight
    }

    // 목적지 도착 여부 확인
    private fun hasReachedDestination(feature: Feature?, currentLat: Double, currentLng: Double): Boolean {
        feature?.let {
            val destinationLat: Double
            val destinationLng: Double

            val coordinates = when (it.geometry.type) {
                "Point" -> it.geometry.getCoordinatesAsDoubleArray()
                "LineString" -> it.geometry.getCoordinatesAsLineString()?.lastOrNull()
                else -> null
            }

            coordinates?.let { coords ->
                destinationLat = coords[1]
                destinationLng = coords[0]
                val distance = calculateDistance(currentLat, currentLng, destinationLat, destinationLng)

                // 10미터 이내에 있으면 도착했다고 간주
                return distance < 10
            }
        }
        return false
    }

    // LineString 경로 상에 사용자가 있는지 확인
    private fun isPointNearLine(lat: Double, lng: Double, lineCoords: List<List<Double>>): Boolean {
        var minDistance = Double.MAX_VALUE
        for (i in 0 until lineCoords.size - 1) {
            val startLat = lineCoords[i][1]
            val startLng = lineCoords[i][0]
            val endLat = lineCoords[i + 1][1]
            val endLng = lineCoords[i + 1][0]

            val distance = pointToLineDistance(lat, lng, startLat, startLng, endLat, endLng)
            if (distance < minDistance) {
                minDistance = distance
            }
        }
        return minDistance < 10 // 경로와 10미터 이내로 가까울 경우
    }

    // 포인트와 선분 사이의 거리 계산
    private fun pointToLineDistance(
        lat: Double,
        lng: Double,
        startLat: Double,
        startLng: Double,
        endLat: Double,
        endLng: Double
    ): Double {
        val a = Location("").apply { latitude = startLat; longitude = startLng }
        val b = Location("").apply { latitude = endLat; longitude = endLng }
        val p = Location("").apply { latitude = lat; longitude = lng }

        return (p.distanceTo(a).toDouble() + p.distanceTo(b).toDouble() - a.distanceTo(b).toDouble())
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
                    clearNavigationState()
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

    // 네비게이션 중단
    fun stopNavigation() {
        val navigationApi = RestClient.createService(NavigationApi::class.java)

        viewModelScope.launch {
            navigationApi.stopNavigation(isWatch = true).enqueue(object : Callback<Void> {
                override fun onResponse(call: Call<Void>, response: Response<Void>) {
                    if (response.isSuccessful) {
                        Log.d("NavigationViewModel", "길안내 중단 성공")
                        clearNavigationState()
                        locationService?.stopLocationUpdates()
                    } else {
                        Log.d("NavigationViewModel", "길안내 중단 실패: ${response.errorBody()?.string()}")
                    }
                }

                override fun onFailure(call: Call<Void>, t: Throwable) {
                    Log.d("NavigationViewModel", "길안내 중단 실패: ${t.message}")
                }
            })
        }
    }

    // 네비게이션 상태 초기화
    fun clearNavigationState() {
        _navigationCommand.value = "clear_navigation"
        _navigationState.value = NavigationState()
    }

    // 네비게이션 상태 체크
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

    // 네이게이션 정보 불러오기
    fun getNavigation() {
        _navigationCommand.value = "get_navigation"
        val navigationApi = RestClient.createService(NavigationApi::class.java)

        viewModelScope.launch {
            try {
                val response = navigationApi.getNavigation()
                response.enqueue(object : Callback<NavigationResponse> {
                    override fun onResponse(call: Call<NavigationResponse>, response: Response<NavigationResponse>) {
                        if (response.isSuccessful) {
                            Log.d("NavigationViewModel", "길안내 정보 받기 성공: $response")
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
