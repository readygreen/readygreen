package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
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

@Composable
fun MainScreen(navController: NavHostController) {
    val buttonList = listOf(
        ButtonIconModel(R.drawable.bookmark_icon, "자주가는 목적지"),
        ButtonIconModel(R.drawable.voice_search_icon, "음성검색"),
        ButtonIconModel(R.drawable.map_icon, "주변 신호등 보기"),
        ButtonIconModel(R.drawable.navigation_icon, "길안내"),
        ButtonIconModel(R.drawable.navigation_icon, "워치 연결 해제")
    )

    var showModal by remember { mutableStateOf(false) }

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
                    when (item.label) {
                        "자주가는 목적지" -> {
                            navController.navigate("bookmarkScreen")
                        }
                        "음성검색" -> {
                            navController.navigate("searchScreen")
                        }
                        "주변 신호등 보기" -> {
                            navController.navigate("mapScreen")
                        }
                        "길안내" -> {
                            navController.navigate("navigationScreen")
                        }
                        "워치 연결 해제" -> {
                            showModal = true
                        }
                    }
                })
            }
        }

        if (showModal) {
            ModalItem(
                title = "연결 해제",
                message = "정말로 연결을 해제하시겠습니까?",
                onConfirm = {
                    TokenManager.clearToken()
                    showModal = false
                    navController.navigate("LinkScreen") {
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
