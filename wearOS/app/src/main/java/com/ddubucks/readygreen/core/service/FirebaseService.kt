package com.ddubucks.readygreen.core.service

import android.content.Intent
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FirebaseMessagingService : FirebaseMessagingService() {
    companion object {
        const val MESSAGE_TYPE_NAVIGATION = "1"
        const val MESSAGE_TYPE_CLEAR = "2"
    }

    private var isRequestInProgress = false

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d("FCM", "메세지 수신: ${remoteMessage.from}")

        remoteMessage.data.isNotEmpty().let {
            Log.d("FCM", "메세지 데이터: ${remoteMessage.data}")
            val messageType = remoteMessage.data["type"] ?: "unknown"

            if (!isRequestInProgress) {
                isRequestInProgress = true
                val intent = Intent("com.ddubucks.readygreen.NAVIGATION")
                intent.putExtra("type", messageType)

                Log.d("FCM", "broadcast 전송: $messageType")
                LocalBroadcastManager.getInstance(applicationContext).sendBroadcast(intent)

                // 상태 초기화
                when (messageType) {
                    MESSAGE_TYPE_NAVIGATION, MESSAGE_TYPE_CLEAR -> {
                        Log.d("FCM", "메세지 타입: $messageType")
                        resetRequestState()
                    }
                    else -> {
                        Log.d("FCM", "메세지 타입: $messageType")
                        resetRequestState()
                    }
                }
            } else {
                Log.d("FCM", "이미 함수가 실행중입니다.")
            }
        }
    }

    override fun onNewToken(token: String) {
        Log.d("FCM", "새 토큰: $token")
    }

    fun resetRequestState() {
        isRequestInProgress = false
        Log.d("FCM", "요청 상태 초기화")
    }
}
