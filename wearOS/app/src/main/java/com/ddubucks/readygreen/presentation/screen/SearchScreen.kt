package com.ddubucks.readygreen.presentation.screen

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
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel
import h3Style
import kotlinx.coroutines.delay
import pStyle

@Composable
fun SearchScreen(navController: NavHostController, viewModel: SearchViewModel) {
    val mike by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.search_mike))

    // 음성 인식 결과 리스트
    var voiceResults by remember { mutableStateOf(emptyList<String>()) }

    val searchResults by viewModel.searchResults.collectAsState() // ViewModel에서 검색 결과 가져오기

    // 음성 인식 결과 처리
    val speechLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult(),
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val spokenText: String? = result.data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.get(0)
            spokenText?.let {
                voiceResults = voiceResults + it // 음성 인식 결과를 추가
                viewModel.updateVoiceResult(it) // ViewModel에 전달하여 검색 수행
            }
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

    LaunchedEffect(Unit) {
        startSpeechRecognition()
    }

    // 검색 결과가 업데이트되면 결과 화면으로 이동
    LaunchedEffect(searchResults) {
        if (searchResults.isNotEmpty()) {
            val resultList = searchResults.joinToString(",")
            navController.navigate("searchResultScreen/$resultList")
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
            modifier = Modifier.size(140.dp)
        )

        // 수동으로 결과 확인
        Button(
            onClick = {
                val resultList = searchResults.joinToString(",")
                navController.navigate("searchResultScreen/$resultList")
            },
            modifier = Modifier.padding(top = 20.dp)
        ) {
            Text("결과 확인하기")
        }
    }
}
