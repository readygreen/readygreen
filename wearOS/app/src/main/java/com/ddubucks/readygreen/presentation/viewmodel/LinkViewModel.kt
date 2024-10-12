package com.ddubucks.readygreen.presentation.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.TokenManager
import com.ddubucks.readygreen.presentation.retrofit.link.LinkApi
import kotlinx.coroutines.launch

class LinkViewModel : ViewModel() {

    private val fcmViewModel = FcmViewModel()

    fun checkAuth(
        email: String,
        authNumber: String,
        onResult: (Boolean, String) -> Unit
    ) {
        viewModelScope.launch {
            try {
                val linkApi = RestClient.createService(LinkApi::class.java)
                val response = linkApi.checkAuth(email, authNumber)
                val accessToken = response.string()

                if (accessToken.isNotEmpty()) {
                    Log.d("LinkViewModel", "access 토큰: $accessToken")
                    TokenManager.saveToken(accessToken)

                    onLoginSuccess()
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

    private fun onLoginSuccess() {
        fcmViewModel.registerFcm()
    }
}
