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
import androidx.navigation.NavHostController
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.Text
import com.airbnb.lottie.compose.*
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.presentation.theme.Black
import h3Style
import kotlinx.coroutines.delay
import pStyle

@Composable
fun SearchScreen(navController: NavHostController, viewModel: SearchViewModel) {

    val mike by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.search_mike))

    // 음성 인식 결과 리스트
    var voiceResults by remember { mutableStateOf(emptyList<String>()) }

    val speechLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult(),
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val spokenText: String? = result.data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.get(0)
            spokenText?.let {
                voiceResults = voiceResults + it // 리스트에 결과 추가
                viewModel.updateVoiceResult(it)
            }
        }
    }

    // 음성인식 시작
    fun startSpeechRecognition() {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "ko-KR")
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true) // 오프라인 인식 선호
        }
        speechLauncher.launch(intent)
    }

    // 음성 인식 트리거
    LaunchedEffect(Unit) {
        startSpeechRecognition()
    }

    // 2초간 입력이 없으면 자동으로 결과 보기
    LaunchedEffect(voiceResults) {
        if (voiceResults.isNotEmpty()) {
            delay(2000) // 2초 대기
            navController.navigate("searchResultScreen/${voiceResults.joinToString(",")}")
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
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
            text = if (voiceResults.isEmpty()) "목적지를 말씀해주세요" else voiceResults.last(),
            style = pStyle,
            modifier = Modifier.padding(bottom = 5.dp)
        )

        LottieAnimation(
            composition = mike,
            iterations = LottieConstants.IterateForever,
            modifier = Modifier
                .size(140.dp)
                .fillMaxWidth()
        )

        // SearchResultScreen으로 네비게이션 버튼
        Button(
            onClick = {
                val resultList = voiceResults.joinToString(",")
                navController.navigate("searchResultScreen/$resultList")
            },
            modifier = Modifier.padding(top = 20.dp)
        ) {
            Text("결과 확인하기")
        }
    }
}
