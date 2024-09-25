package com.ddubucks.readygreen.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.core.service.BluetoothService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class BluetoothViewModel(private val bluetoothService: BluetoothService) : ViewModel() {

    private val _bluetoothState = MutableStateFlow<BluetoothState>(BluetoothState.Disconnected)
    val bluetoothState: StateFlow<BluetoothState> get() = _bluetoothState

    // 블루투스 연결 시도
    fun connectToDevice() {
        viewModelScope.launch {
            _bluetoothState.value = BluetoothState.Connecting // 상태를 "연결 중"으로 업데이트
            val result = bluetoothService.connectToDevice()
            _bluetoothState.value = if (result) {
                BluetoothState.Connected  // 연결 성공 시 상태 변경
            } else {
                BluetoothState.Error("Bluetooth 연결에 실패했습니다.") // 연결 실패 시 상태 변경
            }
        }
    }

    // 블루투스 메시지 수신
    fun receiveMessage() {
        viewModelScope.launch {
            val receivedMessage = bluetoothService.receiveMessage()
            receivedMessage?.let {
                // 메시지가 정상적으로 수신된 경우 처리
            } ?: run {
                _bluetoothState.value = BluetoothState.Error("메시지 수신 중 오류 발생")
            }
        }
    }

    // 블루투스 연결 해제
    fun closeConnection() {
        bluetoothService.closeConnection()
        _bluetoothState.value = BluetoothState.Disconnected // 연결 해제 시 상태 변경
    }
}
