package com.ddubucks.readygreen.presentation.screen

import android.Manifest
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.ddubucks.readygreen.presentation.viewmodel.BluetoothViewModel
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.presentation.viewmodel.BluetoothState

@Composable
fun BluetoothConnectionScreen(bluetoothViewModel: BluetoothViewModel) {
    val bluetoothState by bluetoothViewModel.bluetoothState.collectAsState()

    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        when (bluetoothState) {
            is BluetoothState.Connecting -> {
                CircularProgressIndicator()
                Text("Bluetooth 연결 중...")
            }
            is BluetoothState.Connected -> {
                Text("Bluetooth 연결 성공!")
            }
            is BluetoothState.Disconnected -> {
                Text("Bluetooth 연결 해제됨.")
            }
            is BluetoothState.Error -> {
                val errorMessage = (bluetoothState as BluetoothState.Error).message
                Text("오류: $errorMessage")
            }
        }
    }
}
