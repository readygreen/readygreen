package com.ddubucks.readygreen.presentation.screen

import android.Manifest
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.presentation.viewmodel.BluetoothViewModel

@Composable
fun BluetoothConnectionScreen(
    viewModel: BluetoothViewModel = viewModel(),
    connectToBluetoothDevice: () -> Unit,
    receivedMessage: () -> String
) {
    val connected by viewModel.connected
    val message by viewModel.message

    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }

    // 권한 요청 런처
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission(),
        onResult = { isGranted ->
            if (isGranted) {
                isLoading = true
                viewModel.connectToBluetooth(
                    connectToBluetoothDevice = {
                        connectToBluetoothDevice()
                        isLoading = false
                    },
                    receivedMessage = {
                        isLoading = false
                        receivedMessage()
                    }
                )
            } else {
                errorMessage = "Permission denied"
            }
        }
    )

    // UI 구성
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        if (isLoading) {
            CircularProgressIndicator()
        } else if (connected) {
            Text(text = "Connected to Mobile Device")
            Spacer(modifier = Modifier.height(16.dp))
            Text(text = "Received Message: $message")
        } else {
            Button(onClick = {
                errorMessage = ""
                permissionLauncher.launch(Manifest.permission.BLUETOOTH_CONNECT)
            }) {
                Text("Connect to Mobile")
            }
        }

        if (errorMessage.isNotEmpty()) {
            Spacer(modifier = Modifier.height(16.dp))
            Text(text = errorMessage, color = MaterialTheme.colors.error)
        }
    }
}