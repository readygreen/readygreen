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

@Composable
fun BluetoothConnectionScreen(
    bluetoothViewModel: BluetoothViewModel
) {
    val connected by bluetoothViewModel.connected.collectAsState()
    val message by bluetoothViewModel.message.collectAsState()

    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }

    // 권한 요청 런처
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission(),
        onResult = { isGranted ->
            if (isGranted) {
                isLoading = true
                bluetoothViewModel.connectToDevice()
                isLoading = false
            } else {
                errorMessage = "Bluetooth 권한이 필요합니다."
            }
        }
    )

    // TODO 자동화로 변경
    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        if (isLoading) {
            CircularProgressIndicator()
        } else if (connected) {
            Text("Connected to Bluetooth")
            Spacer(modifier = Modifier.height(16.dp))
            Text("Received Message: $message")
        } else {
            Button(onClick = {
                errorMessage = ""
                permissionLauncher.launch(Manifest.permission.BLUETOOTH_CONNECT)
            }) {
                Text("Connect to Bluetooth")
            }
        }

        if (errorMessage.isNotEmpty()) {
            Spacer(modifier = Modifier.height(16.dp))
            Text(text = errorMessage, color = MaterialTheme.colors.error)
        }
    }
}
