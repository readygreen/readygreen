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
import okhttp3.FormBody
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import retrofit2.awaitResponse

class FcmViewModel : ViewModel() {

    // device 토큰 전송
    fun registerFcm(context: Context) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!task.isSuccessful) {
                Log.w("FcmViewModel", "device 토큰 가져오기 실패", task.exception)
                return@addOnCompleteListener
            }
            val deviceToken = task.result

            // FormBody 생성
            val formBody = FormBody.Builder()
                .add("deviceToken", deviceToken)
                .build()

            // RestClient에서 accessToken 처리 포함한 FcmApi 생성
            val fcmApi = RestClient.createService(FcmApi::class.java, context)

            viewModelScope.launch {
                try {
                    val response = withContext(Dispatchers.IO) {
                        fcmApi.registerFcmToken(formBody).awaitResponse()
                    }
                    if (response.isSuccessful) {
                        Log.d("FcmViewModel", "device 토큰 전송 성공")
                    } else {
                        Log.e("FcmViewModel", "device 토큰 전송 실패: ${response.code()}")
                    }
                } catch (e: Exception) {
                    Log.e("FcmViewModel", "device 토큰 전송 중 오류 발생", e)
                }
            }
        }
    }

    // FCM 메시지 전송
    fun sendFcmMessage(context: Context, message: String, distEmail: String, messageType: Int, watch: Boolean) {

        val fcmRequest = JSONObject(
            mapOf(
                "messageType" to messageType,
                "message" to message,
                "distEmail" to distEmail,
                "watch" to watch
            )
        ).toString()

        // FCM API 호출을 위한 서비스 생성 (자동으로 토큰 처리)
        val fcmApi = RestClient.createService(FcmApi::class.java, context)
        val body = fcmRequest.toRequestBody("application/json".toMediaTypeOrNull())

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
