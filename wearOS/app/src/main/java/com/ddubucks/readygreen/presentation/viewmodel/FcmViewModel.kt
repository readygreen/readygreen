package com.ddubucks.readygreen.presentation.viewmodel

import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.TokenManager
import com.ddubucks.readygreen.presentation.retrofit.fcm.FcmApi
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody
import org.json.JSONObject
import retrofit2.awaitResponse

class FcmViewModel : ViewModel() {

    // FCM 토큰 서버로 전송
    fun registerFcm(context: Context) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!task.isSuccessful) {
                Log.w("FcmViewModel", "FCM 토큰 가져오기 실패", task.exception)
                return@addOnCompleteListener
            }
            val deviceToken = task.result
            val accessToken = TokenManager.getToken(context)

            if (accessToken.isNullOrEmpty()) {
                Log.e("FcmViewModel", "Access Token이 없습니다.")
                return@addOnCompleteListener
            }

            // FCM 토큰을 서버로 전송
            val requestBody = JSONObject(mapOf("fcmToken" to deviceToken)).toString()
            val fcmApi = RestClient.createService(FcmApi::class.java, accessToken)
            val body = RequestBody.create("application/json".toMediaTypeOrNull(), requestBody)

            viewModelScope.launch {
                try {
                    val response = withContext(Dispatchers.IO) {
                        fcmApi.registerFcmToken(body).awaitResponse()
                    }
                    if (response.isSuccessful) {
                        Log.d("FcmViewModel", "FCM 토큰 전송 성공")
                    } else {
                        Log.e("FcmViewModel", "FCM 토큰 전송 실패: ${response.code()}")
                    }
                } catch (e: Exception) {
                    Log.e("FcmViewModel", "FCM 토큰 전송 중 오류 발생", e)
                }
            }
        }
    }

    // FCM 메시지 전송
    fun sendFcmMessage(context: Context, message: String, distEmail: String, messageType: Int, watch: Boolean) {
        val accessToken = TokenManager.getToken(context)

        if (accessToken.isNullOrEmpty()) {
            Log.e("FcmViewModel", "Access Token이 없습니다.")
            return
        }

        // FCM 메시지 전송
        val fcmRequest = JSONObject(
            mapOf(
                "messageType" to messageType,
                "message" to message,
                "distEmail" to distEmail,
                "watch" to watch
            )
        ).toString()

        val fcmApi = RestClient.createService(FcmApi::class.java, accessToken)
        val body = RequestBody.create("application/json".toMediaTypeOrNull(), fcmRequest)

        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    fcmApi.sendFcmMessage(body).awaitResponse()
                }
                if (response.isSuccessful) {
                    Log.d("FcmViewModel", "FCM 메시지 전송 성공")
                } else {
                    Log.e("FcmViewModel", "FCM 메시지 전송 실패: ${response.code()}")
                }
            } catch (e: Exception) {
                Log.e("FcmViewModel", "FCM 메시지 전송 중 오류 발생", e)
            }
        }
    }
}
