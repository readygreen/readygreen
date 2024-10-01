package com.ddubucks.readygreen.presentation.components

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.data.model.ButtonModel
import com.ddubucks.readygreen.presentation.theme.DarkGray

@Composable
fun ButtonItem(
    item: ButtonModel,
    onClick: () -> Unit
) {
    Chip(
        modifier = Modifier.fillMaxWidth(),
        label = { Text(item.label, color = Color.White) },
        colors = ChipDefaults.chipColors(
            backgroundColor = DarkGray
        ),
        onClick = onClick
    )
}
