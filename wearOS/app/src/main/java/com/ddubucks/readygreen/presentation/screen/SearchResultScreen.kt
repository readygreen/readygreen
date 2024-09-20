package com.ddubucks.readygreen.presentation.screen

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.items
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.data.model.ButtonModel
import com.ddubucks.readygreen.presentation.components.ButtonItem
import com.ddubucks.readygreen.presentation.theme.Black

@Composable
fun SearchResultScreen(voiceResults: List<String>, onRetryClick: () -> Unit) {

    ScalingLazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {

        items(voiceResults) { result ->
            ButtonItem(item = ButtonModel(result), onClick = {
                Log.d("SearchResultScreen", "버튼 클릭: $result")
            })
        }

        item {
            ButtonItem(item = ButtonModel("음성 다시 입력"), onClick = {
                onRetryClick
            })
        }
    }
}
