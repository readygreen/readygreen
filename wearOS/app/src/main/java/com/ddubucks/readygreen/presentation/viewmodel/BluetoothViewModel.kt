package com.ddubucks.readygreen.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.core.service.BluetoothService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class BluetoothViewModel(private val bluetoothService: BluetoothService) : ViewModel() {

    private val _connected = MutableStateFlow(false)
    val connected: StateFlow<Boolean> get() = _connected

    private val _message = MutableStateFlow("")
    val message: StateFlow<String> get() = _message

    // 블루투스 연결 시도
    fun connectToDevice() {
        viewModelScope.launch {
            val result = bluetoothService.connectToDevice()
            _connected.value = result
        }
    }

    // 블루투스 메시지 수신
    fun receiveMessage() {
        viewModelScope.launch {
            val receivedMessage = bluetoothService.receiveMessage()
            receivedMessage?.let {
                _message.value = it
            }
        }
    }

    // 블루투스 연결 해제
    fun closeConnection() {
        bluetoothService.closeConnection()
        _connected.value = false
    }
}