package com.ddubucks.readygreen.core.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.ddubucks.readygreen.R
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FirebaseMessagingService : FirebaseMessagingService() {

    // 메세지 수신
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d("FCM", "Message received from: ${remoteMessage.from}")
        remoteMessage.data.isNotEmpty().let {
            Log.d("FCM", "Message data payload: ${remoteMessage.data}")
            val messageBody  = remoteMessage.data["key"] ?: "No Data"
            showNotification(messageBody)
        }
    }

    override fun onNewToken(token: String) {
        Log.d("FCM", "New token: $token")
    }

    // 알림 표시
    private fun showNotification(messageBody: String) {
        val channelId = "fcm_default_channel"
        val notificationId = 1

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "FCM Notifications",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.map_icon)  // 알림 아이콘
            .setContentTitle("FCM Sync")        // 알림 제목
            .setContentText(messageBody)        // 알림 내용 (서버에서 받은 메시지)
            .setPriority(NotificationCompat.PRIORITY_HIGH)  // 알림 우선순위

        with(NotificationManagerCompat.from(this)) {
            notify(notificationId, notificationBuilder.build())
        }
    }
}
