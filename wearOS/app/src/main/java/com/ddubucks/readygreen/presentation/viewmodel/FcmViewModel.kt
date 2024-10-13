package com.ddubucks.readygreen.presentation.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.fcm.FcmApi
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.FormBody
import retrofit2.awaitResponse

class FcmViewModel : ViewModel() {

    // device 토큰 전송
    fun registerFcm() {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!task.isSuccessful) {
                Log.w("FcmViewModel", "device 토큰 가져오기 실패", task.exception)
                return@addOnCompleteListener
            }
            val deviceToken = task.result
            Log.d("FCM", "device 토큰 : ${deviceToken}")

            val formBody = FormBody.Builder()
                .add("deviceToken", deviceToken)
                .build()

            val fcmApi = RestClient.createService(FcmApi::class.java)

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
}
