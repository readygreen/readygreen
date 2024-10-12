package com.ddubucks.readygreen.presentation.retrofit.fcm

data class FcmRequest(
    val messageType: Number,
    val message: String,
    val distEmail: String,
    val watch: Boolean,
)