package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.TextButton
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.presentation.components.TextInput
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.DarkGray
import com.ddubucks.readygreen.presentation.theme.White
import com.ddubucks.readygreen.presentation.theme.Yellow
import h1Style
import pStyle

@Composable
fun LinkEmailScreen(navController: NavController) {

    var text by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "언제그린",
            style = h1Style,
            color = Yellow,
        )
        Spacer(modifier = Modifier.height(10.dp))
        Text(
            text = "이메일을 입력해주세요",
            color = White,
            style = pStyle,
        )
        Spacer(modifier = Modifier.height(8.dp))

        TextInput(
            value = text,
            onValueChange = { newText -> text = newText },
            placeholderText = "이메일 입력",
            keyboardType = KeyboardType.Email,
            fontSize = 14
        )
        Spacer(modifier = Modifier.height(10.dp))
        TextButton(
            onClick = {
                navController.navigate("linkScreen/$text")
            },
            modifier = Modifier
                .height(40.dp)
                .fillMaxWidth(0.4f),
            shape = RoundedCornerShape(40.dp),
            colors = ButtonDefaults.textButtonColors(
                containerColor = DarkGray,
            )
        ) {
            Text(
                text = "다음으로",
                fontSize = 12.sp,
                color = White
            )
        }
    }
}
