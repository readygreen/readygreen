package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
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
import com.ddubucks.readygreen.presentation.theme.Black
import h1Style

@Composable
fun MainScreen(navController: NavHostController) {

    val buttonList = listOf(
        ButtonIconModel(R.drawable.bookmark_icon, "자주가는 목적지"),
        ButtonIconModel(R.drawable.voice_search_icon, "음성검색"),
        ButtonIconModel(R.drawable.map_icon, "지도보기")
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {

        Text(
            text = "언제그린",
            color = Color.Yellow,
            style = h1Style,
            modifier = Modifier.padding(bottom = 10.dp, top = 20.dp)
        )

        ScalingLazyColumn {
            items(buttonList) { item ->
                ButtonIconItem(item = item, onClick = {
                    when (item.label) {
                        "자주가는 목적지" -> {
                            navController.navigate("bookmarkScreen")
                        }
                        "음성검색" -> {
                            navController.navigate("searchScreen")
                        }
                        "지도보기" -> {
                            navController.navigate("mapScreen")
                        }
                    }
                })
            }
        }
    }
}
