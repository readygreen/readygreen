package com.ddubucks.readygreen.presentation.screen

import SearchViewModel
import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.ScalingLazyColumn
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.items
import com.ddubucks.readygreen.data.model.ButtonModel
import com.ddubucks.readygreen.presentation.components.ButtonItem
import com.ddubucks.readygreen.presentation.theme.Black
import h3Style


@Composable
fun SearchResultScreen(viewModel: SearchViewModel) {
    val voiceResult by viewModel.voiceResult.collectAsState()

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

        // 음성인식 결과를 버튼에 출력
        val buttonList = listOf(
            ButtonModel(voiceResult)
        )

        ScalingLazyColumn {
            items(buttonList) { item ->
                ButtonItem(item = item, onClick = {
                    Log.d("SearchResultScreen", "버튼 클릭: ${item.label}")
                })
            }
        }
    }
}
