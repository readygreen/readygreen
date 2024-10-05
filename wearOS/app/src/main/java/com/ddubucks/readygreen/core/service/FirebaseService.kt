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
        Log.d("FCM", "Message received from: ${remoteMessage.from}")

        remoteMessage.data.isNotEmpty().let {
            Log.d("FCM", "Message data payload: ${remoteMessage.data}")
            val messageType = remoteMessage.data["type"] ?: "unknown"

            if (!isRequestInProgress) {
                isRequestInProgress = true
                val intent = Intent("com.ddubucks.readygreen.NAVIGATION")
                intent.putExtra("type", messageType)

                Log.d("FirebaseMessagingService", "Sending broadcast with type: $messageType")
                LocalBroadcastManager.getInstance(applicationContext).sendBroadcast(intent)
            } else {
                Log.d("FCM", "Request already in progress, ignoring this message.")
            }
        }
    }

    override fun onNewToken(token: String) {
        Log.d("FCM", "New token: $token")
    }

    fun resetRequestState() {
        isRequestInProgress = false
    }
}
