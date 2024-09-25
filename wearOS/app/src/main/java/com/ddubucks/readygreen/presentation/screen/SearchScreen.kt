package com.ddubucks.readygreen.presentation.screen

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.speech.RecognizerIntent
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.navigation.NavHostController
import androidx.wear.compose.material.Text
import com.airbnb.lottie.compose.*
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.Yellow
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel
import h3Style
import pStyle

@Composable
fun SearchScreen(navController: NavHostController, viewModel: SearchViewModel) {
    val mike by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.search_mike))
    val context = LocalContext.current

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

    // 음성인식 시작 함수 정의
    fun startSpeechRecognition() {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "ko-KR")
        }
        speechLauncher.launch(intent)
    }

    // 권한 요청을 위한 런처
    val requestAudioPermissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            startSpeechRecognition() // 권한이 승인되면 음성 인식 시작
        } else {
            // 권한이 거부되었을 때 처리
            Toast.makeText(context, "음성 인식 권한이 필요합니다.", Toast.LENGTH_SHORT).show()

            // 앱 설정으로 이동하여 사용자가 수동으로 권한을 설정할 수 있도록 안내
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", context.packageName, null)
            }
            context.startActivity(intent)
        }
    }

    // 권한 확인 및 요청
    LaunchedEffect(Unit) {
        when {
            ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED -> {
                // 권한이 있으면 음성 인식 시작
                startSpeechRecognition()
            }
            else -> {
                // 권한이 없으면 권한 요청
                requestAudioPermissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
            }
        }
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
            color = Yellow,
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
    }
}
