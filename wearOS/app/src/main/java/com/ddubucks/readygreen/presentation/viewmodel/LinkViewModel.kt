package com.ddubucks.readygreen.presentation.viewmodel

import android.content.Context
import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.TokenManager
import com.ddubucks.readygreen.presentation.retrofit.link.LinkApi
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.launch
import okhttp3.ResponseBody

class LinkViewModel() : ViewModel() {

    fun checkAuth(
        context: Context,
        email: String,
        authNumber: String,
        onResult: (Boolean, String) -> Unit
    ) {

        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!task.isSuccessful) {
                Log.w("LinkViewModel", "Device 토큰 가져오기 실패", task.exception)
                onResult(false, "Device 토큰 가져오기 실패")
                return@addOnCompleteListener
            }
            val deviceToken = task.result
            Log.d("LinkViewModel", "Device 토큰: $deviceToken")

            viewModelScope.launch {
                try {
                    val linkApi = RestClient.createService(LinkApi::class.java, "")
                    val response = linkApi.checkAuth(email, authNumber, deviceToken)
                    val accessToken = response.string()

                    if (accessToken.isNotEmpty()) {
                        Log.d("LinkViewModel", "받은 토큰: $accessToken")
                        TokenManager.saveToken(context, accessToken)

                        onResult(true, "인증 성공")
                    } else {
                        onResult(false, "토큰이 없습니다.")
                    }
                } catch (e: Exception) {
                    Log.e("LinkViewModel", "오류 발생", e)
                    onResult(false, "오류 발생: ${e.message}")
                }
            }
        }
    }
}
