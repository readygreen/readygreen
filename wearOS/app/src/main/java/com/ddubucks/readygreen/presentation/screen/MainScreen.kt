package com.ddubucks.readygreen.presentation.screen

import android.Manifest
import android.content.Context
import android.util.Log
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.ScalingLazyColumn
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.items
import androidx.navigation.NavHostController
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.data.model.ButtonIconModel
import com.ddubucks.readygreen.presentation.components.ButtonIconItem
import com.ddubucks.readygreen.presentation.components.ModalItem
import com.ddubucks.readygreen.presentation.retrofit.TokenManager
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.Yellow
import h1Style
import android.widget.Toast
import androidx.lifecycle.viewmodel.compose.viewModel
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel


@Composable
fun MainScreen(navController: NavHostController, locationService: LocationService) {
    val buttonList = listOf(
        ButtonIconModel(R.drawable.bookmark_icon, "자주가는 목적지"),
        ButtonIconModel(R.drawable.voice_search_icon, "음성검색"),
        ButtonIconModel(R.drawable.map_icon, "주변 신호등 보기"),
        ButtonIconModel(R.drawable.navigation_icon, "길안내"),
        ButtonIconModel(R.drawable.unlink_icon, "워치 연결 해제")
    )

    val navigationViewModel: NavigationViewModel = viewModel()
    var showModal by remember { mutableStateOf(false) }
    var locationPermissionGranted by remember { mutableStateOf(false) }

    // 위치 권한 요청
    val locationPermissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        locationPermissionGranted = isGranted
        if (!isGranted) {
            Toast.makeText(navController.context, "위치 권한이 필요합니다.", Toast.LENGTH_LONG).show()
        }
    }

    // 권한 확인 및 요청
    LaunchedEffect(Unit) {
        if (locationService.hasLocationPermission()) {
            locationPermissionGranted = true
        } else {
            locationPermissionLauncher.launch(Manifest.permission.ACCESS_FINE_LOCATION)
        }
    }

    Box(
        modifier = Modifier.fillMaxSize()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Black),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            ScalingLazyColumn {
                item {
                    Text(
                        text = "언제그린",
                        color = Yellow,
                        style = h1Style,
                        modifier = Modifier.padding(bottom = 10.dp, top = 20.dp)
                    )
                }

                items(buttonList) { item ->
                    ButtonIconItem(item = item, onClick = {
                        if (locationPermissionGranted) {
                            when (item.label) {
                                "자주가는 목적지" -> navController.navigate("bookmarkScreen")
                                "음성검색" -> navController.navigate("searchScreen")
                                "주변 신호등 보기" -> navController.navigate("mapScreen")
                                "길안내" -> navController.navigate("navigationScreen")
                                "워치 연결 해제" -> {
                                    showModal = true
                                    Log.d("MainScreen", "모달 표시 상태: $showModal")
                                }
                            }
                        } else {
                            Toast.makeText(navController.context, "위치 권한이 필요합니다.", Toast.LENGTH_LONG).show()
                        }
                    })
                }
            }
        }

        if (showModal) {
            ModalItem(
                title = "워치 연결 해제",
                message = "정말로 연결을 해제하시겠습니까?",
                onConfirm = {
                    TokenManager.clearToken()
                    navigationViewModel.clearState()
                    showModal = false
                    navController.navigate("linkEmailScreen") {
                        popUpTo(navController.graph.startDestinationId) { inclusive = true }
                    }
                },
                onCancel = {
                    showModal = false
                }
            )
        }
    }
}