package com.ddubucks.readygreen.presentation.screen

import android.speech.tts.TextToSpeech
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.presentation.components.Modal
import com.ddubucks.readygreen.presentation.retrofit.navigation.NavigationState
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.Gray
import com.ddubucks.readygreen.presentation.theme.Red
import com.ddubucks.readygreen.presentation.theme.White
import com.ddubucks.readygreen.presentation.theme.Primary
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel
import h3Style
import pStyle
import secStyle
import java.util.*

@Composable
fun NavigationScreen(
    navController: NavHostController,
    navigationViewModel: NavigationViewModel = viewModel()
) {
    val navigationState = navigationViewModel.navigationState.collectAsState().value
    val (showExitDialog, setShowExitDialog) = remember { mutableStateOf(false) }

    // TTS 인스턴스 생성
    val context = LocalContext.current
    var ttsReady by remember { mutableStateOf(false) }
    var tts by remember { mutableStateOf<TextToSpeech?>(null) }

    // TTS 초기화
    LaunchedEffect(Unit) {
        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.KOREAN
                ttsReady = true
            }
        }
    }

    // TTS 자원 해제
    DisposableEffect(Unit) {
        onDispose {
            tts?.shutdown()
        }
    }

    // currentDescription이 바뀔 때마다 음성 출력
    LaunchedEffect(navigationState.currentDescription) {
        if (ttsReady && navigationState.currentDescription != null) {
            tts?.speak(navigationState.currentDescription, TextToSpeech.QUEUE_FLUSH, null, null)
        }
    }

    BackHandler(enabled = navigationState.isNavigating) {
        if (navigationState.isNavigating) {
            setShowExitDialog(true)
        } else {
            navController.popBackStack()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "경로 안내",
            style = h3Style,
            color = Primary
        )

        Spacer(modifier = Modifier.height(10.dp))

        if (navigationState.isNavigating) {
            NavigationInfo(navigationState)
        } else {
            Text(
                text = "길안내 중이 아닙니다.",
                style = pStyle,
                color = White
            )
        }
    }

    if (showExitDialog) {
        Modal(
            title = "길 안내 중지",
            message = "길 안내를 중지하시겠습니까? 아니오를 누르면 길안내가 유지됩니다.",
            onConfirm = {
                navigationViewModel.stopNavigation()
                setShowExitDialog(false)
                navController.popBackStack()
            },
            onCancel = {
                setShowExitDialog(false)
                navController.popBackStack()
            }
        )
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
            11 -> R.drawable.arrow_straight                // 직진
            12, 16, 17 -> R.drawable.arrow_left            // 좌회전 및 관련 좌회전
            13, 18, 19 -> R.drawable.arrow_right           // 우회전 및 관련 우회전
            14 -> R.drawable.arrow_back                    // 유턴
            else -> R.drawable.arrow_straight              // 나머지 값은 안내 없음 처리
        } ),
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
        text = "남은 거리: ${navigationState.remainingDistance?.let { String.format("%.1f", it) } ?: "정보 없음"} m",
        style = pStyle,
        color = White
    )

    Spacer(modifier = Modifier.height(10.dp))

    navigationState.trafficLightColor?.let { color ->
        Text(
            text = "${navigationState.trafficLightRemainingTime ?: "정보 없음"}초",
            style = secStyle,
            color = when (color) {
                "GREEN" -> Color.Green
                "RED" -> Red
                else -> Gray
            }
        )
    }
}
