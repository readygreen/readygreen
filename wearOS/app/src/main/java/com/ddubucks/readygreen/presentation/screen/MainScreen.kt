// MainScreen.kt
package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.presentation.components.ButtonIconListScreen
import com.ddubucks.readygreen.presentation.theme.Black
import h1Style

@Composable
fun MainScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),  // 배경을 검정색으로 설정
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "언제그린",
            color = Color.Yellow,
            fontSize = 22.sp,
            style = h1Style,
            modifier = Modifier.padding(bottom = 10.dp, top = 16.dp)

        )

        // 버튼 목록 컴포넌트를 불러와서 리스트 표시
        ButtonIconListScreen()
    }
}
