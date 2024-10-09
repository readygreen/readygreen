package com.ddubucks.readygreen.presentation.screen

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.speech.RecognizerIntent
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import androidx.activity.compose.rememberLauncherForActivityResult
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
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.Primary
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel
import h3Style
import pStyle
import java.util.*

@Composable
fun SearchScreen(
    navController: NavHostController,
    apiKey: String,
    searchViewModel: SearchViewModel
) {
    val mike by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.search_mike))
    var voiceResults by remember { mutableStateOf(emptyList<String>()) }
    val searchResults by searchViewModel.searchResults.collectAsState()
    val searchStatus by searchViewModel.searchStatus.collectAsState()
    val context = LocalContext.current
    val locationService = remember { LocationService(context) }

    // TTS 인스턴스 생성
    var ttsReady by remember { mutableStateOf(false) }
    var tts by remember { mutableStateOf<TextToSpeech?>(null) }

    // 음성 인식 실행 상태 변수
    var startSpeechRecognition by remember { mutableStateOf(false) }

    // 음성 인식 결과 추가
    val speechLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val data = result.data
            val matches = data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            matches?.let {
                voiceResults = listOf(it[0])
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

    // TTS 초기화
    LaunchedEffect(Unit) {
        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.KOREAN
                ttsReady = true

                // TTS 음성 출력 완료 시 콜백 설정
                tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) {
                        // 음성 출력 시작 시
                    }

                    override fun onDone(utteranceId: String?) {
                        // TTS 음성 출력이 끝난 후 음성 인식 시작
                        startSpeechRecognition = true
                    }

                    override fun onError(utteranceId: String?) {
                        // 에러 처리
                    }
                })
            }
        }
    }

    // TTS 음성 출력 함수
    fun speak(text: String) {
        if (ttsReady) {
            tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "utteranceId")
        }
    }

    // TTS 자원 해제
    DisposableEffect(Unit) {
        onDispose {
            tts?.shutdown()
        }
    }

    // TTS 음성이 끝난 후 음성 인식 시작
    LaunchedEffect(startSpeechRecognition) {
        if (startSpeechRecognition) {
            startSpeechRecognition()
        }
    }

    // 화면 시작과 동시에 "목적지를 말씀해주세요" 출력
    LaunchedEffect(ttsReady) {
        if (ttsReady) {
            speak("목적지를 말씀해주세요")
        }
    }

    // 권한 확인 및 음성 인식 시작
    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            startSpeechRecognition()
        }
    }

    LaunchedEffect(Unit) {
        if (ContextCompat.checkSelfPermission(
                context, Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            permissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
        }
    }

    // voiceResults와 searchResults 초기화
    LaunchedEffect(navController.currentBackStackEntry) {
        voiceResults = emptyList()
        searchViewModel.clearSearchResults()
    }

    // 음성 검색과 위치 추적
    LaunchedEffect(voiceResults) {
        if (voiceResults.isNotEmpty()) {
            Log.d("SearchScreen", "음성 인식 결과: ${voiceResults.first()}")
            locationService.getLastLocation { location ->
                if (location != null) {
                    val latitude = location.latitude
                    val longitude = location.longitude
                    Log.d("SearchScreen", "현재 위치: $latitude, $longitude")

                    searchViewModel.searchPlaces(
                        latitude = latitude,
                        longitude = longitude,
                        keyword = voiceResults.first(),
                        apiKey = apiKey
                    )
                } else {
                    Log.e("SearchScreen", "현재 위치를 가져올 수 없습니다.")
                }
            }
        }
    }

    // 검색 상태 변화에 따른 화면 전환
    LaunchedEffect(searchStatus) {
        if (searchStatus == "ZERO_RESULTS" || searchResults.isNotEmpty()) {
            navController.currentBackStackEntry?.savedStateHandle?.set("searchResults", searchResults)
            Log.d("SearchScreen", "검색 결과 화면으로 이동")
            navController.navigate("searchResultScreen")
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
            color = Primary,
            style = h3Style,
        )
        Spacer(modifier = Modifier.height(10.dp))
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
