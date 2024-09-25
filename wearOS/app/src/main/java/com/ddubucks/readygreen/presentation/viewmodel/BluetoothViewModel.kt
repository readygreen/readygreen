package com.ddubucks.readygreen.presentation.viewmodel

import androidx.compose.runtime.MutableState
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel


class BluetoothViewModel : ViewModel() {

    // 상태를 mutableStateOf로 초기화
    var connected: MutableState<Boolean> = mutableStateOf(false)
    var message: MutableState<String> = mutableStateOf("")

    fun connectToBluetooth(connectToBluetoothDevice: () -> Unit, receivedMessage: () -> String) {
        try {
            // 블루투스 연결 시도
            connectToBluetoothDevice()
            connected.value = true // MutableState에서 .value로 상태 설정
            message.value = receivedMessage() // MutableState에서 .value로 메시지 설정
        } catch (e: Exception) {
            connected.value = false
            println("Connection failed: ${e.message}")
        }
    }
}

