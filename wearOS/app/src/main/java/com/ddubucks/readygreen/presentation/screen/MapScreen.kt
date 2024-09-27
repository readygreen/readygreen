package com.ddubucks.readygreen.presentation.screen

import android.Manifest
import android.content.pm.PackageManager
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.data.model.PinModel
import com.ddubucks.readygreen.presentation.components.createTrafficlightBitmap
import com.ddubucks.readygreen.presentation.theme.Black
import com.google.android.gms.location.LocationServices
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
    val context = LocalContext.current
    val fusedLocationClient = remember { LocationServices.getFusedLocationProviderClient(context) }
    val locationService = LocationService()
    var latitude by remember { mutableStateOf<Double?>(null) }
    var longitude by remember { mutableStateOf<Double?>(null) }
    var permissionGranted by remember { mutableStateOf(false) }

    // 위치 권한 요청
    val locationPermission = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        permissionGranted = isGranted
        if (isGranted) {
            locationService.getLastLocation(fusedLocationClient) { lat, long ->
                latitude = lat
                longitude = long
            }
        }
    }

    // 권한이 없을 때 요청
    LaunchedEffect(key1 = Unit) {
        if (ContextCompat.checkSelfPermission(
                context, Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            locationPermission.launch(Manifest.permission.ACCESS_FINE_LOCATION)
        } else {
            permissionGranted = true
            locationService.getLastLocation(fusedLocationClient) { lat, long ->
                latitude = lat
                longitude = long
            }
        }
    }

    if (latitude == null || longitude == null) {
        // 현재 위치를 로딩 중일 때 로딩 표시
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator()
        }
    } else {
        // 현재 위치로 카메라를 설정
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
            verticalArrangement = Arrangement.Top // 수직 정렬을 상단으로 설정
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
