package com.ddubucks.readygreen.presentation.screen

import SearchViewModel
import android.app.Activity
import android.content.Intent
import android.speech.RecognizerIntent
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.Text
import com.airbnb.lottie.compose.*
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.presentation.theme.Black
import h3Style
import pStyle

@Composable
fun SearchScreen(viewModel: SearchViewModel) {

    val composition by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.search_mike))

    // 음성 인식 결과를 저장할 변수
    var voiceInput by remember { mutableStateOf("목적지를 말씀해주세요") }

    // ActivityResultLauncher를 사용하여 음성 인식 결과를 받기 위한 설정
    val speechLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult(),
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val spokenText: String? = result.data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.get(0)
            voiceInput = spokenText ?: "인식 실패"
            viewModel.updateVoiceResult(voiceInput)
        }
    }

    // 음성인식 시작
    fun startSpeechRecognition() {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "ko-KR")
        }
        speechLauncher.launch(intent)
    }

    // 음성 인식 트리거
    LaunchedEffect(Unit) {
        startSpeechRecognition()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),  // 배경색 설정
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "음성검색",
            color = Color.Yellow,
            style = h3Style,
            modifier = Modifier.padding(bottom = 14.dp, top = 16.dp)
        )

        Text(
            text = voiceInput,  // 음성 인식 결과
            style = pStyle,
            modifier = Modifier.padding(bottom = 5.dp)
        )

        LottieAnimation(
            composition = composition,
            iterations = LottieConstants.IterateForever,
            modifier = Modifier
                .size(140.dp)
                .fillMaxWidth()
        )

        // 음성 인식을 다시 시작
        Button(
            onClick = { startSpeechRecognition() },
            modifier = Modifier.padding(top = 20.dp)
        ) {
            Text("음성 다시 입력")
        }
    }
}
