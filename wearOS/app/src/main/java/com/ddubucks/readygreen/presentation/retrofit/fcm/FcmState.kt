package com.ddubucks.readygreen.presentation.retrofit.fcm

sealed class FcmState {
    object Loading : FcmState()
    object Success : FcmState()
    object Failure : FcmState()
}