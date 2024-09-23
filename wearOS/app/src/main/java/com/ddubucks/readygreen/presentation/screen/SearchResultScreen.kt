package com.ddubucks.readygreen.presentation.screen

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.items
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.data.model.ButtonModel
import com.ddubucks.readygreen.presentation.components.ButtonItem
import com.ddubucks.readygreen.presentation.theme.Black
import h3Style
import pStyle

@Composable
fun SearchResultScreen(voiceResults: List<String>, onRetryClick: () -> Unit) {

    // 전달받은 검색 결과 로그 출력
    Log.d("SearchResultScreen", "전달받은 검색 결과: $voiceResults")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {

        Text(
            text = "검색 결과",
            color = Color.Yellow,
            style = h3Style,
            modifier = Modifier.padding(bottom = 14.dp, top = 16.dp)
        )

        Text(
            text = "목적지를 선택해주세요",
            style = pStyle,
            modifier = Modifier.padding(bottom = 5.dp)
        )

        // 전달받은 검색 결과를 버튼으로 출력
        ScalingLazyColumn(
            modifier = Modifier.fillMaxSize().background(Black),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            items(voiceResults) { result ->
                ButtonItem(item = ButtonModel(result), onClick = {
                    // 선택한 장소에 대한 처리 (예: 지도 화면으로 이동 등)
                    Log.d("SearchResultScreen", "선택한 장소: $result")
                })
            }

            item {
                ButtonItem(item = ButtonModel("음성 다시 입력"), onClick = {
                    onRetryClick()
                })
            }
        }
    }
}
