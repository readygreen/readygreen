package com.ddubucks.readygreen.presentation.components

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.data.model.ButtonModel
import com.ddubucks.readygreen.presentation.theme.DarkGray

@Composable
fun ButtonText(
    item: ButtonModel,
    onClick: () -> Unit
) {
    Chip(
        modifier = Modifier
            .padding(bottom = 4.5.dp)
            .fillMaxWidth(),
        label = { Text(item.label, color = Color.White) },
        colors = ChipDefaults.chipColors(
            backgroundColor = DarkGray
        ),
        onClick = onClick
    )
}
