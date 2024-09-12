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
import com.ddubucks.readygreen.presentation.viewmodel.BookmarkViewModel
import h3Style

@Composable
fun BookmarkScreen(viewModel: BookmarkViewModel = androidx.lifecycle.viewmodel.compose.viewModel()) {
    val bookmarks by viewModel.bookmark.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "자주가는 목적지",
            style = h3Style,
            color = Color.Yellow,
            modifier = Modifier.padding(bottom = 10.dp, top = 16.dp)
        )

//        ScalingLazyColumn {
//            items(bookmarks) { bookmark ->
//                Text(text = bookmark.name)
//            }
//        }

        // TODO 더미데이터 삭제
        val buttonList = listOf(
            ButtonIconModel(R.drawable.bookmark_home, "집"),
            ButtonIconModel(R.drawable.bookmark_office, "회사"),
            ButtonIconModel(R.drawable.bookmark_default, "나만의 맛집"),
            ButtonIconModel(R.drawable.bookmark_default, "또다른 맛집")
        )

        ScalingLazyColumn {
            items(buttonList) { item ->
                ButtonIconItem(item = item, onClick = {
                    Log.d("BookmarkScreen", "버튼 클릭: ${item.label}")
                })
            }
        }
        }
    }

