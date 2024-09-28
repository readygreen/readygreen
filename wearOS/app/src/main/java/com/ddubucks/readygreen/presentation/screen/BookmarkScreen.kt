package com.ddubucks.readygreen.presentation.screen

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
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

@Composable
fun BookmarkScreen(viewModel: BookmarkViewModel = androidx.lifecycle.viewmodel.compose.viewModel()) {
    val bookmarks by viewModel.bookmark.collectAsState()

    val buttonList = listOf(
        ButtonIconModel(R.drawable.bookmark_home, "집"),
        ButtonIconModel(R.drawable.bookmark_office, "회사"),
        ButtonIconModel(R.drawable.bookmark_default, "나만의 맛집"),
        ButtonIconModel(R.drawable.bookmark_default, "또다른 맛집")
    )

    ScalingLazyColumn {
        item {
            Text(
                text = "자주가는 목적지",
                style = h3Style,
                color = Yellow,
                modifier = Modifier.padding(bottom = 10.dp, top = 30.dp)
            )
        }
        item {
            Spacer(modifier = Modifier.height(10.dp))
        }
        items(buttonList) { item ->
                ButtonIconItem(item = item, onClick = {
                    Log.d("BookmarkScreen", "버튼 클릭: ${item.label}")
                })
            }
        }
    }