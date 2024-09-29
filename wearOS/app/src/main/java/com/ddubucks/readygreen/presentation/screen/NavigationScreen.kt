package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.presentation.theme.Red
import com.ddubucks.readygreen.presentation.theme.Yellow
import h3Style
import pStyle
import secStyle

@Composable
fun NavigationScreen(
    name: String?,
    lat: Float?,
    lng: Float?
) {


    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "경로 안내",
            style = h3Style,
            color = Yellow,
        )
        Icon(
            painter = painterResource(id = R.drawable.arrow_left),
            contentDescription = "방향",
            tint = Color.Unspecified,
            modifier = Modifier
                .size(80.dp)
                .padding(top = 20.dp)
        )
        Text(
            text = "50m 앞 신호등",
            fontWeight = FontWeight.Bold,
            style = pStyle,
            color = Color.White,
            modifier = Modifier.padding(top = 15.dp)
        )
        Text(
            text = "40초",
            fontWeight = FontWeight.Bold,
            style = secStyle,
            color = Red,
            modifier = Modifier.padding(top = 6.dp)
        )
    }
}