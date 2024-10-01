package com.ddubucks.readygreen.presentation.screen

import android.content.Context
import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.viewmodel.MapViewModel
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapUiSettings
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.MarkerState
import com.google.maps.android.compose.rememberCameraPositionState

@Composable
fun MapScreen(
    locationService: LocationService,
    mapViewModel: MapViewModel
) {
    // 위치 데이터를 상태로 관리
    var latitude by remember { mutableStateOf<Double?>(null) }
    var longitude by remember { mutableStateOf<Double?>(null) }

    // Compose에서 context는 composable 함수 외부에서 가져옵니다.
    val context = LocalContext.current

    // 비동기 위치 데이터를 가져오는 작업
    LaunchedEffect(Unit) {
        locationService.getLastLocation { location ->
            latitude = location?.latitude
            longitude = location?.longitude
        }
    }

    // 위도와 경도가 설정되면 ViewModel의 API 호출
    LaunchedEffect(latitude, longitude) {
        if (latitude != null && longitude != null) {
            // 이 부분에서 LocalContext.current 대신 context를 사용합니다.
            mapViewModel.getMap(context, latitude!!, longitude!!)
        }
    }

    // 위치 정보를 아직 가져오지 못했을 때 로딩 표시
    if (latitude == null || longitude == null) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator()
        }
    } else {
        val locationState = LatLng(latitude!!, longitude!!)
        val cameraPositionState = rememberCameraPositionState {
            position = CameraPosition.fromLatLngZoom(locationState, 16f)
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Black),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Top
        ) {
            GoogleMap(
                modifier = Modifier.fillMaxSize(),
                cameraPositionState = cameraPositionState,
                uiSettings = MapUiSettings(myLocationButtonEnabled = true)
            ) {
                val mapData by mapViewModel.mapData.collectAsState()
                mapData?.let { response ->
                    if (response.blinkerDTOs.isNotEmpty()) {
                        response.blinkerDTOs.forEach { blinkerDTO ->
                            Log.d("MapScreen", "BlinkerDTO: $blinkerDTO")
                            Marker(
                                state = MarkerState(
                                    position = LatLng(blinkerDTO.latitude, blinkerDTO.longitude)
                                ),
                                title = "Blinker ${blinkerDTO.id}"
                            )
                        }
                    } else {
                        Log.e("MapScreen", "blinkerDTOs 리스트가 비어 있습니다.")
                    }
                }

            }
        }
    }
}
