package com.ddubucks.readygreen.presentation.viewmodel

import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.TokenManager
import com.ddubucks.readygreen.presentation.retrofit.link.LinkApi
import kotlinx.coroutines.launch
import okhttp3.ResponseBody

class LinkViewModel(private val fcmViewModel: FcmViewModel) : ViewModel() {

    // 인증번호 확인 로직
    fun checkAuth(
        context: Context,
        email: String,
        authNumber: String,
        onResult: (Boolean, String) -> Unit
    ) {
        viewModelScope.launch {
            try {
                // Retrofit을 이용한 API 요청
                val linkApi = RestClient.createService(LinkApi::class.java, "")
                val response = linkApi.checkAuth(email, authNumber)
                val token = response.string()

                if (token.isNotEmpty()) {
                    Log.d("LinkViewModel", "받은 토큰: $token")
                    TokenManager.saveToken(context, token)  // 토큰 저장

                    // 로그인 성공 후 FCM 토큰 전송
                    onLoginSuccess(context, token)

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

    // 로그인 성공 시 처리 로직
    private fun onLoginSuccess(context: Context, accessToken: String) {
        fcmViewModel.registerFcm(context)  // FCM 토큰 등록
    }
}
