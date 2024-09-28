package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.ddubucks.readygreen.data.model.PinModel
import com.ddubucks.readygreen.presentation.components.createTrafficlightBitmap
import com.ddubucks.readygreen.presentation.theme.Black
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapUiSettings
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.MarkerState
import com.google.maps.android.compose.rememberCameraPositionState

@Composable
fun MapScreen() {
    var latitude by remember { mutableStateOf<Double?>(null) }
    var longitude by remember { mutableStateOf<Double?>(null) }

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
            verticalArrangement = Arrangement.Top
        ) {
            GoogleMap(
                modifier = Modifier.fillMaxSize(),
                cameraPositionState = cameraPositionState,
                uiSettings = MapUiSettings(myLocationButtonEnabled = true)
            ) {
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
}
