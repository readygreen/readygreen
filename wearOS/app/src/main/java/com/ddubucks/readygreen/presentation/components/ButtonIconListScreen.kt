package com.ddubucks.readygreen.presentation.components

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.wear.compose.material.ScalingLazyColumn
import androidx.wear.compose.material.items
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.model.ButtonIconModel

@Composable
fun ButtonIconListScreen(navController: NavHostController) {
    val buttonList = listOf(
        ButtonIconModel(R.drawable.favorite_icon, "자주가는 목적지"),
        ButtonIconModel(R.drawable.voice_search_icon, "음성검색"),
        ButtonIconModel(R.drawable.map_icon, "지도보기")
    )

    ScalingLazyColumn {
        items(buttonList) { item ->
            ButtonIconItem(item = item, onClick = {
                when (item.label) {
                    "자주가는 목적지" -> {
                        navController.navigate("favoriteScreen")
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
