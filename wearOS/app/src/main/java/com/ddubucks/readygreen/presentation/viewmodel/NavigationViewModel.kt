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
    private var currentIndex = 0 // 현재 안내 중인 경로 포인트 인덱스
    private var pointIndexList: List<Int> = emptyList() // Type이 Point인 인덱스 리스트

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
            route = navigationResponse.routeDTO.features // 경로 정보

            // Type이 Point인 포인트 인덱스를 수집
            pointIndexList = route?.mapIndexedNotNull { index, feature ->
                if (feature.geometry.type == "Point") index else null
            } ?: emptyList()

            // 첫 번째 포인트 설명 업데이트
            updateCurrentDescription()

            // 위치 업데이트 빈도 설정
            locationService?.adjustLocationRequest(
                priority = Priority.PRIORITY_HIGH_ACCURACY,
                interval = 500 // 0.5초마다 위치 업데이트
            )

            // 위치 업데이트 시작
            locationService?.startLocationUpdates { location -> updateNavigation(location) }

            _navigationState.value = _navigationState.value.copy(
                isNavigating = true,
                destinationName = navigationResponse.routeDTO.features.lastOrNull()?.properties?.name ?: "알 수 없음"
            )
        } ?: run {
            Log.d("NavigationViewModel", "경로 정보 받기 실패")
            _navigationState.value = NavigationState(isNavigating = false)
        }
    }

    private fun updateNavigation(currentLocation: Location) {
        this.currentLocation = currentLocation // 위치 업데이트 시 저장

        val currentLat = currentLocation.latitude
        val currentLng = currentLocation.longitude

        // 다음 안내 중인 포인트가 있는지 확인
        if (currentIndex + 1 < pointIndexList.size) {
            val nextFeature = route?.get(pointIndexList[currentIndex + 1]) // 다음 Point 타입의 Feature 가져오기
            nextFeature?.let { feature ->
                val coordinates = feature.geometry.getCoordinatesAsDoubleArray()
                coordinates?.let {
                    val distance = calculateDistance(currentLat, currentLng, it[1], it[0])

                    // 현재 위치가 다음 포인트 반경 10미터 이내인지 확인
                    if (distance < 15.0) {
                        // 포인트의 description 확인
                        if (feature.properties.description == "도착") {
                            Log.d("NavigationViewModel", "목적지에 도착했습니다!")
                            finishNavigation() // 길안내 종료
                        } else {
                            Log.d("NavigationViewModel", "다음 지점으로 이동: ${feature.properties.description}")
                            currentIndex++ // 다음 포인트로 이동
                            updateCurrentDescription() // 다음 포인트의 설명 업데이트
                        }
                    }
                }
            }
        }
    }


    // 두 좌표 사이의 거리를 계산
    private fun calculateDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double): Double {
        val location1 = Location("").apply {
            latitude = lat1
            longitude = lng1
        }
        val location2 = Location("").apply {
            latitude = lat2
            longitude = lng2
        }
        return location1.distanceTo(location2).toDouble()
    }

    // 현재 안내 중인 포인트의 description을 업데이트
    private fun updateCurrentDescription() {
        pointIndexList.getOrNull(currentIndex)?.let { index ->
            route?.get(index)?.let { feature ->
                if (feature.geometry.type == "Point") {
                    _navigationState.value = _navigationState.value.copy(
                        currentDescription = feature.properties.description ?: "안내 없음"
                    )
                }
            }
        }
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


    // 좌표 반올림
    private fun roundToSix(value: Double): Double {
        return String.format("%.6f", value).toDouble()
    }
}
