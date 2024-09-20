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
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.viewmodel.LocationViewModel
import h3Style
import pStyle


@Composable
fun MapScreen(locationViewModel: LocationViewModel) {
    // 현재 위치를 구독
    val locationState = locationViewModel.locationFlow.collectAsState()

    // 위치 업데이트 요청 (Composable 함수 안에서 실행)
    LaunchedEffect(Unit) {
        locationViewModel.startLocationUpdates()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // 지도 타이틀
        Text(
            text = "지도",
            color = Color.Yellow,
            style = h3Style,
            modifier = Modifier.padding(bottom = 10.dp, top = 16.dp)
        )

        // 현재 위치 출력 (if-else 사용)
        if (locationState.value != null) {
            val location = locationState.value!!
            Text(
                text = "현재 위치: ${location.latitude}, ${location.longitude}",
                color = Color.White,
                style = pStyle,
                modifier = Modifier.padding(top = 16.dp)
            )
        } else {
            Text(
                text = "위치 정보를 불러오는 중...",
                style = pStyle,
                color = Color.White,
                modifier = Modifier.padding(top = 16.dp)
            )
        }
    }
}
