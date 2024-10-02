package com.ddubucks.readygreen.presentation.screen

import android.graphics.Paint.Style
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.presentation.retrofit.navigation.NavigationState
import com.ddubucks.readygreen.presentation.theme.Red
import com.ddubucks.readygreen.presentation.theme.White
import com.ddubucks.readygreen.presentation.theme.Yellow
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel
import h3Style
import pStyle
import secStyle


// TODO map/guide/check : 어플 시작시 길안내중인지 아닌지 확인 -> 맞으면 map/guide get 요청으로 안내 불러오기, 아니면 냅두기
// TODO map/guide get : 길안내중이라는 알림 받았을때 요청 불러오기
// TODO map/guide post : 길안내 완료
// TODO map/guide delete : 길안내 중단

@Composable
fun NavigationScreen(
    navigationViewModel: NavigationViewModel = viewModel()
) {
    val navigationState = navigationViewModel.navigationState.collectAsState().value

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(text = "경로 안내", style = h3Style, color = Yellow)

        Spacer(modifier = Modifier.height(10.dp))

        if (navigationState.isNavigating) {
            NavigationInfo(navigationState)
        } else {
            Text(text = "길안내 중이 아닙니다.", color = Color.White)
        }
    }
}

@Composable
fun NavigationInfo(navigationState: NavigationState) {
    Text(
        text = navigationState.destinationName ?: "목적지 정보 없음",
        style = pStyle,
        color = White
    )

    Spacer(modifier = Modifier.height(10.dp))

    Icon(
        painter = painterResource(id = when (navigationState.nextDirection) {
            11 -> R.drawable.arrow_straight
            12 -> R.drawable.arrow_left
            13 -> R.drawable.arrow_right
            else -> R.drawable.arrow_straight
        }),
        contentDescription = "방향",
        tint = Color.Unspecified,
        modifier = Modifier.size(40.dp)
    )

    Spacer(modifier = Modifier.height(10.dp))

    Text(
        text = navigationState.currentDescription ?: "안내 없음",
        style = pStyle,
        color = White
    )

    Spacer(modifier = Modifier.height(10.dp))

    Text(
        text = "45초",
        style = secStyle,
        color = Red
    )
}