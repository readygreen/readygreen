package com.ddubucks.readygreen.presentation.screen

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
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
import com.ddubucks.readygreen.presentation.components.ModalItem
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
    navController: NavHostController,
    navigationViewModel: NavigationViewModel = viewModel()
) {
    val context = LocalContext.current
    val navigationState = navigationViewModel.navigationState.collectAsState().value
    val (showExitDialog, setShowExitDialog) = remember { mutableStateOf(false) }

    // 길 안내 중일 때만 뒤로 가기 핸들러가 작동
    BackHandler(enabled = navigationState.isNavigating) {
        if (navigationState.isNavigating) {
            setShowExitDialog(true)  // 길안내 중일 때 모달 띄우기
        } else {
            navController.popBackStack()  // 길 안내 중이 아닐 경우 바로 뒤로가기
        }
    }

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
            // 네비게이션이 활성화되어 있을 때 안내 정보를 보여줌
            NavigationInfo(navigationState)
        } else {
            // 네비게이션이 비활성화 상태일 때
            Text(text = "길안내 중이 아닙니다.", color = Color.White)
        }
    }

    // 모달 처리: 길 안내 중일 때만 표시
    if (showExitDialog) {
        ModalItem(
            title = "길 안내 중지",
            message = "길 안내를 중지하시겠습니까? 아니오를 누르면 백그라운드에서 길안내가 유지됩니다.",
            onConfirm = {
                navigationViewModel.stopNavigation(context)  // 길 안내 중지
                setShowExitDialog(false)
                navController.popBackStack()  // 뒤로 가기
            },
            onCancel = {
                setShowExitDialog(false)
            }
        )
    }
}

@Composable
fun NavigationInfo(navigationState: NavigationState) {
    // 네비게이션 정보 UI 구성
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
        text = "45초", // 예시 시간 표시
        style = secStyle,
        color = Red
    )
}
