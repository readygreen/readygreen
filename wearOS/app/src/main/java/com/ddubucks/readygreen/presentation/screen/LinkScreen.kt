package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.TextButton
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.presentation.theme.*
import com.ddubucks.readygreen.presentation.viewmodel.LinkViewModel
import h1Style
import pStyle
import android.widget.Toast
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.em
import com.ddubucks.readygreen.presentation.components.TextInput

@Composable
fun LinkScreen(
    navController: NavController,
    viewModel: LinkViewModel = viewModel(),
    email: String,
) {
    var authNumber by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf("") }
    val context = LocalContext.current

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
            color = Primary,
        )

        Spacer(modifier = Modifier.height(10.dp))

        Text(
            text = "인증번호를 입력해주세요",
            color = White,
            style = pStyle,
        )

        Spacer(modifier = Modifier.height(8.dp))

        TextInput(
            value = authNumber,
            onValueChange = { newText ->
                if (newText.length <= 6 && newText.all { it.isDigit() }) {
                    authNumber = newText
                }
            },
            placeholderText = "인증번호 입력",
            keyboardType = KeyboardType.Number,
            fontSize = 20,
            letterSpacing = 0.3.em
        )

        Spacer(modifier = Modifier.height(10.dp))

        TextButton(
            onClick = {
                viewModel.checkAuth(
                    email,
                    authNumber
                ) { success, message ->
                    if (success) {
                        navController.navigate("mainScreen") {
                            popUpTo(navController.graph.startDestinationId) { inclusive = true }
                        }
                    } else {
                        errorMessage = "이메일 또는 인증번호를 확인해주세요."
                        Toast.makeText(context, errorMessage, Toast.LENGTH_SHORT).show()
                    }
                }
            },
            modifier = Modifier
                .height(40.dp)
                .fillMaxWidth(0.4f),
            shape = RoundedCornerShape(40.dp),
            colors = ButtonDefaults.textButtonColors(
                containerColor = if (authNumber.length == 6) Secondary else DarkGray,
            )
        ) {
            Text(
                text = "시작하기",
                color = if (authNumber.length == 6) Black else White,  // 입력에 따라 텍스트 색상 변경
                fontSize = 12.sp
            )
        }
    }
}
