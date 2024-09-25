package com.ddubucks.readygreen.presentation.viewmodel

sealed class BluetoothState {
    object Connecting : BluetoothState()        // 연결 중
    object Connected : BluetoothState()         // 연결 성공
    object Disconnected : BluetoothState()      // 연결 해제 또는 실패
    data class Error(val message: String) : BluetoothState() // 연결 실패 시 에러 메시지
}