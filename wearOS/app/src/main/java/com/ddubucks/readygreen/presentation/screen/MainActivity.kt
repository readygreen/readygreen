package com.ddubucks.readygreen.presentation.screen

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.ddubucks.readygreen.presentation.theme.ReadyGreenTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // MainActivity는 setContent로 Compose UI를 설정
        setContent {
            ReadyGreenTheme {
                MainScreen()  // MainScreen으로 실제 UI 로딩
            }
        }
    }
}
