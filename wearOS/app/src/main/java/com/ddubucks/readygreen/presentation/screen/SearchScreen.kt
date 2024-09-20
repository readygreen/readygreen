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
            val newResult = spokenText ?: "인식 실패"
            voiceResults = voiceResults + newResult  // 리스트에 결과 추가
            viewModel.updateVoiceResult(newResult)
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

        // SearchResultScreen으로 네비게이션
        Button(
            onClick = {
                // voiceResults를 NavController로 넘길 수 있도록 인코딩
                val resultList = voiceResults.joinToString(",")
                navController.navigate("searchResultScreen/$resultList")
            },
            modifier = Modifier.padding(top = 20.dp)
        ) {
            Text("결과 확인하기")
        }
    }
}
