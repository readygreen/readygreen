package com.ddubucks.readygreen.presentation.screen

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.TextButton
import androidx.compose.material3.TextField
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.presentation.theme.*
import com.ddubucks.readygreen.presentation.viewmodel.LinkViewModel
import com.google.firebase.messaging.FirebaseMessaging
import h1Style
import pStyle

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
            color = Yellow,
        )
        Spacer(modifier = Modifier.height(10.dp))
        Text(
            text = "인증번호를 입력해주세요",
            color = White,
            style = pStyle,
            modifier = Modifier.padding(top = 10.dp)
        )
        Spacer(modifier = Modifier.height(8.dp))

        TextField(
            value = authNumber,
            onValueChange = { newText ->
                if (newText.length <= 6 && newText.all { it.isDigit() }) {
                    authNumber = newText
                }
            },
            modifier = Modifier.fillMaxWidth(0.75f),
            keyboardOptions = KeyboardOptions.Default.copy(keyboardType = KeyboardType.Number),
            placeholder = { Text(text = "인증번호 입력", color = Gray) }
        )

        Spacer(modifier = Modifier.height(10.dp))

        TextButton(
            onClick = {
                viewModel.checkAuth(
                    context,
                    email,
                    authNumber
                ) { success, message ->
                    if (success) {
                        navController.navigate("mainScreen") {
                            popUpTo("linkEmailScreen") { inclusive = true }
                        }
                    } else {
                        errorMessage = message
                    }
                }
            },
            colors = ButtonDefaults.textButtonColors(containerColor = DarkGray)
        ) {
            Text(text = "시작하기", color = White, fontSize = 12.sp)
        }

        if (errorMessage.isNotEmpty()) {
            Spacer(modifier = Modifier.height(10.dp))
            Text(text = errorMessage, color = Red)
        }
    }
}