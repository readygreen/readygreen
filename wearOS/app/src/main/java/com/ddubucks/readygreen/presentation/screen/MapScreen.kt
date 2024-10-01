package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.components.createTrafficlightBitmap
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.viewmodel.MapViewModel
import com.google.android.gms.maps.model.BitmapDescriptorFactory
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
    var latitude by remember { mutableStateOf<Double?>(null) }
    var longitude by remember { mutableStateOf<Double?>(null) }
    val context = LocalContext.current
    val mapData by mapViewModel.mapData.collectAsState()

    LaunchedEffect(Unit) {
        locationService.getLastLocation { location ->
            latitude = location?.latitude
            longitude = location?.longitude
        }
    }

    LaunchedEffect(latitude, longitude) {
        if (latitude != null && longitude != null) {
            mapViewModel.getMap(context, latitude!!, longitude!!)
        }
    }

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
                mapData?.blinkerDTOs?.forEach { blinkerDTO ->
                    Marker(
                        state = MarkerState(position = LatLng(blinkerDTO.latitude, blinkerDTO.longitude)),
                        title = blinkerDTO.currentState,
                        snippet = "남은 시간: ${blinkerDTO.remainingTime}",
                        icon = BitmapDescriptorFactory.fromBitmap(createTrafficlightBitmap(blinkerDTO))
                    )
                }
            }
        }
    }
}
