package com.ddubucks.readygreen.presentation.screen

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
import com.ddubucks.readygreen.presentation.theme.Red
import com.ddubucks.readygreen.presentation.theme.White
import com.ddubucks.readygreen.presentation.theme.Yellow
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel
import h3Style
import pStyle

@Composable
fun NavigationScreen(
    navigationViewModel: NavigationViewModel = viewModel() // ViewModel 주입
) {
    val navigationState = navigationViewModel.navigationState.collectAsState().value // 경로 상태 구독

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "경로 안내",
            style = h3Style,
            color = Yellow,
        )

        Spacer(modifier = Modifier.height(10.dp))

        if (navigationState.isNavigating) {
            Text(
                text = navigationState.destinationName ?: "목적지 정보 없음",
                style = pStyle,
                color = White,
            )

            Spacer(modifier = Modifier.height(10.dp))

            Icon(
                painter = painterResource(
                    id = when (navigationState.nextDirection) {
                        11 -> R.drawable.arrow_straight
                        12 -> R.drawable.arrow_left
                        13 -> R.drawable.arrow_right
                        else -> R.drawable.arrow_straight
                    }
                ),
                contentDescription = "방향",
                tint = Color.Unspecified,
                modifier = Modifier.size(80.dp)
            )

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = navigationState.currentDescription ?: "안내 없음",
                fontWeight = FontWeight.Bold,
                color = Red,
            )

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = "남은 거리: ${navigationState.remainingDistance?.toInt() ?: 0}m",
                fontWeight = FontWeight.Bold,
                color = White,
            )
        } else {
            Text(
                text = "길안내 중이 아닙니다.",
                color = Color.White
            )
        }
    }
}
