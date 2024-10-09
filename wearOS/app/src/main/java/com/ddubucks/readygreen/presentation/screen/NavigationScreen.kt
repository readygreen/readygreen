package com.ddubucks.readygreen.presentation.screen

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
import com.ddubucks.readygreen.presentation.theme.*
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel
import androidx.compose.runtime.remember
import androidx.compose.runtime.LaunchedEffect
import com.ddubucks.readygreen.presentation.viewmodel.TTSViewModel
import kotlinx.coroutines.delay
import h3Style
import pStyle
import secStyle

@Composable
fun NavigationScreen(
    navController: NavHostController,
    navigationViewModel: NavigationViewModel = viewModel(),
) {
    val navigationState = navigationViewModel.navigationState.collectAsState().value
    val (showExitDialog, setShowExitDialog) = remember { mutableStateOf(false) }
    val (showArrivalDialog, setShowArrivalDialog) = remember { mutableStateOf(false) }

    val context = LocalContext.current
    val ttsViewModel = remember { TTSViewModel(context) }

    LaunchedEffect(navigationState.currentDescription) {
        navigationState.currentDescription?.let { description ->
            ttsViewModel.speakText(description)

            if (description == "도착") {
                ttsViewModel.speakText("목적지에 도착하였습니다")
                setShowArrivalDialog(true)
            }
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

    if (showArrivalDialog) {
        Modal(
            title = "목적지 도착",
            message = "목적지에 도착하셨습니다. 길 안내를 종료하시겠습니까?",
            onConfirm = {
                navigationViewModel.finishNavigation()
                setShowArrivalDialog(false)
                navController.popBackStack()
            },
            onCancel = {
                setShowArrivalDialog(false)
            }
        )
    }
}

@Composable
fun NavigationInfo(navigationState: NavigationState) {
    val (remainingTime, setRemainingTime) = remember { mutableStateOf(navigationState.currentBlinkerInfo?.remainingTime ?: 0) }
    val (currentBlinkerState, setCurrentBlinkerState) = remember { mutableStateOf(navigationState.currentBlinkerInfo?.currentState ?: "RED") }
    val isNavigating = navigationState.isNavigating

    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = navigationState.destinationName ?: "목적지 정보 없음",
            style = pStyle,
            color = White
        )
        Spacer(modifier = Modifier.height(10.dp))

        Icon(
            painter = painterResource(id = when (navigationState.nextDirection) {
                11 -> R.drawable.arrow_straight
                12, 16, 17 -> R.drawable.arrow_left
                13, 18, 19 -> R.drawable.arrow_right
                14 -> R.drawable.arrow_back
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
            text = "${remainingTime}초",
            style = secStyle,
            color = when (currentBlinkerState) {
                "RED" -> Red
                "GREEN" -> Green
                else -> Gray
            }
        )
    }
}
