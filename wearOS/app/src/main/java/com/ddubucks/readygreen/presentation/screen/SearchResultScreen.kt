package com.ddubucks.readygreen.presentation.screen

import android.speech.tts.TextToSpeech
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.items
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.data.model.ButtonModel
import com.ddubucks.readygreen.presentation.components.ButtonText
import com.ddubucks.readygreen.presentation.components.Modal
import com.ddubucks.readygreen.presentation.retrofit.search.SearchCandidate
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.White
import com.ddubucks.readygreen.presentation.theme.Primary
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel
import h3Style
import pStyle
import java.util.*

@Composable
fun SearchResultScreen(
    navController: NavHostController,
    navigationViewModel: NavigationViewModel = viewModel()
) {

    val context = LocalContext.current
    var showConfirmationDialog by remember { mutableStateOf(false) }
    var selectedPlace by remember { mutableStateOf<SearchCandidate?>(null) }

    val searchResults = navController.previousBackStackEntry
        ?.savedStateHandle
        ?.get<List<SearchCandidate>>("searchResults") ?: emptyList()

    // TTS 인스턴스 생성
    var ttsReady by remember { mutableStateOf(false) }
    var tts by remember { mutableStateOf<TextToSpeech?>(null) }

    // TTS 초기화
    LaunchedEffect(Unit) {
        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.KOREAN
                ttsReady = true
            }
        }
    }

    // TTS 자원 해제
    DisposableEffect(Unit) {
        onDispose {
            tts?.shutdown()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Spacer(modifier = Modifier.height(10.dp))
        ScalingLazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .background(Black),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            item {
                Text(
                    text = "검색 결과",
                    color = Primary,
                    style = h3Style,
                )
            }

            item { Spacer(modifier = Modifier.height(20.dp)) }

            item {
                if (searchResults.isNotEmpty()) {
                    Text(
                        text = "목적지를 선택해주세요",
                        color = White,
                        style = pStyle,
                    )
                } else {
                    Text(
                        text = "검색 결과가 없습니다.",
                        color = White,
                        style = pStyle,
                    )
                }
            }

            item { Spacer(modifier = Modifier.height(10.dp)) }

            items(searchResults) { result ->
                ButtonText(item = ButtonModel(result.name), onClick = {
                    selectedPlace = result
                    showConfirmationDialog = true

                    // 선택된 목적지 이름을 TTS로 읽기
                    if (ttsReady && result.name != null) {
                        tts?.speak("${result.name}로 길안내를 시작합니다", TextToSpeech.QUEUE_FLUSH, null, null)
                    }
                })
            }
            item {
                ButtonText(item = ButtonModel("음성 다시 입력"), onClick = {
                    navController.popBackStack()
                })
            }
        }
    }

    if (showConfirmationDialog && selectedPlace != null) {
        Modal(
            title = "길 안내 시작",
            message = "${selectedPlace?.name}로 길 안내를 시작하시겠습니까?",
            onConfirm = {
                val place = selectedPlace
                if (place != null) {
                    navigationViewModel.startNavigation(
                        context,
                        place.geometry.location.lat,
                        place.geometry.location.lng,
                        place.name
                    )
                    navController.navigate("navigationScreen") {
                        popUpTo("mainScreen") { inclusive = false }
                    }
                }
                showConfirmationDialog = false
            },
            onCancel = {
                showConfirmationDialog = false
            }
        )
    }
}
