package com.ddubucks.readygreen.presentation.viewmodel

import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.TokenManager
import com.ddubucks.readygreen.presentation.retrofit.map.MapApi
import com.ddubucks.readygreen.presentation.retrofit.map.MapResponse
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class MapViewModel : ViewModel() {

    private val _mapData = MutableStateFlow<MapResponse?>(null)
    val mapData: StateFlow<MapResponse?> = _mapData

    private var isCountdownRunning = false
    private var countdownJob: Job? = null

    fun getMap(context: Context, latitude: Double, longitude: Double) {
        val accessToken = TokenManager.getToken(context)
        val mapApi = accessToken?.let { RestClient.createService(MapApi::class.java, it) }
        val radius = 500

        viewModelScope.launch {
            try {
                val response = mapApi?.getMap(latitude, longitude, radius)
                if (response != null) {
                    _mapData.value = response
                    Log.d("MapViewModel", "교통 신호 정보 조회 성공")
                } else {
                    Log.e("MapViewModel", "교통 신호 정보 조회 실패")
                }
            } catch (e: Exception) {
                Log.e("MapViewModel", "신호등 정보 조회 중 오류 발생", e)
            }
        }
    }

    fun startCountdown() {
        if (!isCountdownRunning) {
            isCountdownRunning = true
            countdownJob = viewModelScope.launch {
                while (true) {
                    _mapData.value?.let { mapResponse ->
                        val updatedBlinkers = mapResponse.blinkerDTOs.map { blinkerDTO ->
                            if (blinkerDTO.remainingTime > 1) {

                                blinkerDTO.copy(remainingTime = blinkerDTO.remainingTime - 1)
                            } else {

                                when (blinkerDTO.currentState) {
                                    "RED" -> blinkerDTO.copy(
                                        currentState = "GREEN",
                                        remainingTime = blinkerDTO.greenDuration
                                    )
                                    "GREEN" -> blinkerDTO.copy(
                                        currentState = "RED",
                                        remainingTime = blinkerDTO.redDuration
                                    )
                                    else -> blinkerDTO
                                }
                            }
                        }
                        _mapData.value = mapResponse.copy(blinkerDTOs = updatedBlinkers)
                    }

                    delay(1000L)
                }
            }
        }
    }

    fun stopCountdown() {
        countdownJob?.cancel()
        isCountdownRunning = false
    }
}