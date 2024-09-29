package com.ddubucks.readygreen.presentation.screen

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.ScalingLazyColumn
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.items
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.data.model.ButtonIconModel
import com.ddubucks.readygreen.presentation.components.ButtonIconItem
import com.ddubucks.readygreen.presentation.theme.Yellow
import com.ddubucks.readygreen.presentation.viewmodel.BookmarkViewModel
import h3Style
import pStyle

@Composable
fun BookmarkScreen(viewModel: BookmarkViewModel = androidx.lifecycle.viewmodel.compose.viewModel()) {
    val bookmarks by viewModel.bookmark.collectAsState()  // ViewModel에서 북마크 데이터를 수집
    val context = LocalContext.current

    // 북마크 데이터를 서버에서 로드
    LaunchedEffect(Unit) {
        viewModel.getBookmarks(context)
    }

    ScalingLazyColumn {
        item {
            Text(
                text = "자주가는 목적지",
                style = h3Style,
                color = Yellow,
                modifier = Modifier.padding(bottom = 10.dp, top = 30.dp)
            )
        }

        if (bookmarks != null && bookmarks!!.isNotEmpty()) {
            item {
                Text(
                    text = "목적지를 선택해주세요.",
                    style = pStyle,
                    color = Color.White,
                    modifier = Modifier.padding(10.dp)
                )
            }
        } else {
            item {
                Text(
                    text = "저장된 북마크가 없습니다.",
                    style = pStyle,
                    color = Color.White,
                    modifier = Modifier.padding(10.dp)
                )
            }
        }
        if (bookmarks != null && bookmarks!!.isNotEmpty()) {
            items(bookmarks!!) { bookmark ->
                ButtonIconItem(
                    item = ButtonIconModel(
                        icon = R.drawable.bookmark_default,
                        label = bookmark.destinationName
                    ),
                    onClick = {
                        Log.d("BookmarkScreen", "버튼 클릭: ${bookmark.destinationName}")
                    }
                )
            }
        }
    }
}
