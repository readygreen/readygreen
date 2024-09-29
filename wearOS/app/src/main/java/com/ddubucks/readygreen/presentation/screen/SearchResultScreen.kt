package com.ddubucks.readygreen.presentation.screen

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavHostController
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.items
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.data.model.ButtonModel
import com.ddubucks.readygreen.presentation.components.ButtonItem
import com.ddubucks.readygreen.presentation.retrofit.search.SearchCandidate
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.White
import com.ddubucks.readygreen.presentation.theme.Yellow
import h3Style
import pStyle


@Composable
fun SearchResultScreen(
    navController: NavHostController
) {
    // SearchCandidate 리스트를 받습니다.
    val searchResults = navController.previousBackStackEntry
        ?.savedStateHandle
        ?.get<List<SearchCandidate>>("searchResults") ?: emptyList()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Spacer(modifier = Modifier.height(10.dp))
        ScalingLazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .background(Black),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            item {
                Text(
                    text = "검색 결과",
                    color = Yellow,
                    style = h3Style,
                )
            }
            item { Spacer(modifier = Modifier.height(20.dp)) }
            item {
                if (searchResults.isNotEmpty()) {
                    Text(
                        text = "목적지를 선택해주세요",
                        color = White,
                        style = pStyle,
                    )
                } else {
                    Text(
                        text = "검색 결과가 없습니다.",
                        color = White,
                        style = pStyle,
                    )
                }
            }
            item { Spacer(modifier = Modifier.height(10.dp)) }
            items(searchResults) { result ->
                ButtonItem(item = ButtonModel(result.name), onClick = {
                    // 선택된 장소의 이름과 좌표를 navigationScreen으로 넘깁니다.
                    val name = result.name
                    val lat = result.geometry.location.lat
                    val lng = result.geometry.location.lng

                    // navigationScreen으로 이동하며 데이터 전달
                    navController.navigate("navigationScreen/$name/$lat/$lng")

                    Log.d("SearchResultScreen", "선택한 장소: $name, 좌표: $lat, $lng")
                })
            }
            item {
                ButtonItem(item = ButtonModel("음성 다시 입력"), onClick = {
                    navController.popBackStack()
                })
            }
        }
    }
}