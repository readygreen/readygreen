// ButtonIconItem.kt
package com.ddubucks.readygreen.presentation.components

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.wear.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.Icon
import com.ddubucks.readygreen.model.ButtonIconModel
import com.ddubucks.readygreen.presentation.theme.DarkGray  // 회색 가져오기

@Composable
fun ButtonIconItem(item: ButtonIconModel) {
    Chip(
        modifier = Modifier.fillMaxWidth(),
        label = { Text(item.label, color = Color.White) },
        icon = {
            Icon(
                painter = painterResource(id = item.icon),
                contentDescription = null,
                tint = Color.Unspecified,
                modifier = Modifier.size(24.dp)
            )
        },

        colors = ChipDefaults.chipColors(
            backgroundColor = DarkGray
        ),
        onClick = {
            // 버튼 클릭 시 동작
            when (item.label) {
                "자주가는 목적지" -> {
                    // FavoritesActivity로 이동
                }
                "음성검색" -> {
                    // SearchActivity로 이동
                }
                "지도보기" -> {
                    // MapActivity로 이동
                }
            }
        }
    )
}
