package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.data.model.ButtonIconModel
import com.ddubucks.readygreen.data.model.PinModel
import com.ddubucks.readygreen.presentation.components.createTrafficlightBitmap
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.Yellow
import com.ddubucks.readygreen.presentation.viewmodel.LocationViewModel
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.MarkerState
import com.google.maps.android.compose.rememberCameraPositionState
import h3Style
import pStyle


@Composable
fun MapScreen(locationViewModel: LocationViewModel) {
    val locationState = LatLng(36.354946759143, 127.29980994578)
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(locationState, 16f)
    }

    val trafficlightList = listOf(
        PinModel("red", 45, 36.3540567592, 127.29980994578),
        PinModel("green", 46, 36.355946759143, 127.30080994578),
        PinModel("green", 10, 36.35594559143, 127.29880994578)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Top // 수직 정렬을 상단으로 설정
    ) {
        GoogleMap(
            modifier = Modifier.fillMaxSize(),
            cameraPositionState = cameraPositionState
        ) {
            // 현재위치 마커
            Marker(
                state = MarkerState(position = locationState),
                title = null,
                snippet = null
            )
            // 신호등 정보 마커
            trafficlightList.forEach { pin ->
                Marker(
                    state = MarkerState(position = LatLng(pin.latitude, pin.longitude)),
                    title = pin.state,
                    snippet = "번호: ${pin.number}",
                    icon = BitmapDescriptorFactory.fromBitmap(createTrafficlightBitmap(pin)) // 커스텀 비트맵 사용
                )
            }
        }
    }
}
