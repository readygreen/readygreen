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

class LinkViewModel : ViewModel() {

    private val linkApi = RestClient.create(LinkApi::class.java)

    fun checkAuth(
        context: Context,
        email: String,
        authNumber: String,
        onResult: (Boolean, String) -> Unit
    ) {
        viewModelScope.launch {
            try {
                val responseBody: ResponseBody = linkApi.checkAuth(email, authNumber)
                val responseString = responseBody.string()
                val token = responseString

                if (token.isNotEmpty()) {
                    Log.d("LinkViewModel", "받은 토큰: $token")
                    TokenManager.saveToken(context, token)
                } else {
                    Log.e("LinkViewModel", "토큰이 없습니다.")
                }

                onResult(true, "인증 성공")
            } catch (e: Exception) {
                Log.e("LinkViewModel", "오류 발생", e)
                onResult(false, "오류가 발생했습니다: ${e.message}")
            }
        }
    }
}
