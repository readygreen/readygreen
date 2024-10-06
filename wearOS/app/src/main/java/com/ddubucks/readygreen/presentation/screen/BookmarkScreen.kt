package com.ddubucks.readygreen.presentation.screen

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.navigation.NavHostController
import androidx.wear.compose.material.ScalingLazyColumn
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.items
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.data.model.ButtonIconModel
import com.ddubucks.readygreen.presentation.components.ButtonIcon
import com.ddubucks.readygreen.presentation.components.Modal
import com.ddubucks.readygreen.presentation.retrofit.bookmark.BookmarkResponse
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.Yellow
import com.ddubucks.readygreen.presentation.viewmodel.BookmarkViewModel
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel
import h3Style
import pStyle

@Composable
fun BookmarkScreen(
    bookmarkViewModel: BookmarkViewModel = androidx.lifecycle.viewmodel.compose.viewModel(),
    navigationViewModel: NavigationViewModel = androidx.lifecycle.viewmodel.compose.viewModel(),
    navController: NavHostController,
) {
    val bookmarks by bookmarkViewModel.bookmark.collectAsState(initial = emptyList())
    val context = LocalContext.current
    var showModal by remember { mutableStateOf(false) }
    var selectedBookmark by remember { mutableStateOf<BookmarkResponse?>(null) }

    LaunchedEffect(Unit) {
        bookmarkViewModel.getBookmarks()
    }

    Box(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Black),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            ScalingLazyColumn {
                item {
                    Text(
                        text = "자주가는 목적지",
                        style = h3Style,
                        color = Yellow,
                    )
                }
                item {
                    Spacer(modifier = Modifier.height(10.dp))
                }
                if (bookmarks.isNotEmpty()) {
                    item {
                        Text(
                            text = "목적지를 선택해주세요.",
                            style = pStyle,
                            color = Color.White,
                        )
                    }
                    item {
                        Spacer(modifier = Modifier.height(10.dp))
                    }
                    items(bookmarks) { bookmark ->
                        val iconResId = when (bookmark.name) {
                            "회사" -> R.drawable.bookmark_office
                            "집" -> R.drawable.bookmark_home
                            else -> R.drawable.bookmark_default
                        }
                        ButtonIcon(
                            item = ButtonIconModel(
                                icon = iconResId,
                                label = bookmark.destinationName
                            ),
                            onClick = {
                                Log.d("BookmarkScreen", "북마크 버튼 클릭: ${bookmark.destinationName}")
                                selectedBookmark = bookmark
                                showModal = true
                            }
                        )
                    }
                } else {
                    item {
                        Text(
                            text = "저장된 북마크가 없습니다.",
                            style = pStyle,
                            color = Color.White,
                        )
                    }
                }
            }
        }

        if (showModal && selectedBookmark != null) {
            Modal(
                title = "길안내 시작",
                message = "${selectedBookmark?.destinationName}으로 길안내를 시작할까요?",
                onConfirm = {
                    showModal = false
                    selectedBookmark?.let { bookmark ->
                        navigationViewModel.startNavigation(
                            context,
                            bookmark.latitude,
                            bookmark.longitude,
                            bookmark.destinationName
                        )
                        navController.navigate("navigationScreen") {
                            popUpTo("mainScreen") { inclusive = false }
                        }
                    }
                },
                onCancel = {
                    showModal = false
                }
            )
        }
    }
}
