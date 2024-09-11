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
import androidx.navigation.NavHostController
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.presentation.components.MainButtonList
import com.ddubucks.readygreen.presentation.theme.Black
import h1Style


@Composable
fun MainScreen(navController: NavHostController) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
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

        MainButtonList(navController = navController)
    }
}
