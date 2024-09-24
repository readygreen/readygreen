package com.ddubucks.readygreen.presentation.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.BuildConfig
import com.ddubucks.readygreen.core.network.LocationService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.io.IOException
import java.net.URLEncoder

class SearchViewModel(private val locationService: LocationService) : ViewModel() {

    private val _searchResults = MutableStateFlow<List<String>>(emptyList())
    val searchResults: StateFlow<List<String>> get() = _searchResults

    private val client = OkHttpClient()

    init {
        // 위치 업데이트 요청
        locationService.requestLocationUpdates()
    }

    // 장소 검색 API 호출
    fun searchPlaces(query: String) {
        viewModelScope.launch {
            try {
                val currentLocation = locationService.locationFlow.value
                val locationBias = if (currentLocation != null) {
                    "location=${currentLocation.latitude},${currentLocation.longitude}&radius=5000"
                } else {
                    "location=37.5665,126.9780&radius=5000" // 기본 위치 (서울)
                }

                val encodedQuery = URLEncoder.encode(query, "UTF-8")
                val url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&$locationBias&key=${BuildConfig.MAPS_API_KEY}"

                val request = Request.Builder().url(url).build()

                client.newCall(request).enqueue(object : okhttp3.Callback {
                    override fun onFailure(call: okhttp3.Call, e: IOException) {
                        Log.e("SearchViewModel", "API 호출 실패: ${e.message}")
                    }

                    override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                        if (!response.isSuccessful) {
                            Log.e("SearchViewModel", "API 호출 실패 - 응답 코드: ${response.code}, 메시지: ${response.message}")
                            return
                        }

                        response.body?.string()?.let { responseBody ->
                            val json = JSONObject(responseBody)
                            val results = json.getJSONArray("results")

                            val places = mutableListOf<String>()
                            for (i in 0 until minOf(results.length(), 5)) {
                                val place = results.getJSONObject(i)
                                val name = place.getString("name")
                                places.add(name)
                            }

                            _searchResults.value = places
                            Log.d("SearchViewModel", "최종 선택된 장소: $places")
                        }
                    }
                })
            } catch (e: Exception) {
                Log.e("SearchViewModel", "API 호출 중 오류 발생", e)
            }
        }
    }

    // 음성 인식 결과를 기반으로 검색 실행
    fun updateVoiceResult(result: String) {
        searchPlaces(result)
    }
}
