package com.ddubucks.readygreen.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.presentation.viewmodel.BookmarkViewModel

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
            color = Color.Yellow,
            modifier = Modifier.padding(bottom = 10.dp, top = 16.dp)
        )

        LazyColumn {
            items(bookmarks) { bookmark ->
                Text(text = bookmark.name)
            }
        }
    }
}
