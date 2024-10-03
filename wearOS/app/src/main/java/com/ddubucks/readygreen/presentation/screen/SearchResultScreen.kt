package com.ddubucks.readygreen.presentation.screen

import android.util.Log
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
import com.ddubucks.readygreen.presentation.components.ButtonItem
import com.ddubucks.readygreen.presentation.components.ModalItem
import com.ddubucks.readygreen.presentation.retrofit.search.SearchCandidate
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.White
import com.ddubucks.readygreen.presentation.theme.Yellow
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel
import h3Style
import pStyle

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
                    color = Yellow,
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
                ButtonItem(item = ButtonModel(result.name), onClick = {
                    selectedPlace = result
                    showConfirmationDialog = true
                })
            }
            item {
                ButtonItem(item = ButtonModel("음성 다시 입력"), onClick = {
                    navController.popBackStack()
                })
            }
        }
    }

    if (showConfirmationDialog && selectedPlace != null) {
        ModalItem(
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
