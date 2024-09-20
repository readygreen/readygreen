package com.ddubucks.readygreen.presentation.theme

import androidx.wear.compose.material.Colors
import androidx.compose.runtime.Composable
import androidx.wear.compose.material.MaterialTheme

private val DarkColorPalette = Colors(
    primary = Yellow,
    background = Black,
    surface = DarkGray,
    onPrimary = Black,
    onBackground = White
)

@Composable
fun ReadyGreenTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colors = DarkColorPalette,
        content = content
    )
}
