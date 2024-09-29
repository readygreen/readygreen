package com.ddubucks.readygreen.presentation.viewmodel

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.TokenManager
import com.ddubucks.readygreen.presentation.retrofit.link.LinkApi
import com.ddubucks.readygreen.presentation.retrofit.link.LinkResponse
import kotlinx.coroutines.launch

class LinkViewModel : ViewModel() {

    private val linkApi = RestClient.create(LinkApi::class.java)

    fun checkAuth(context: Context, email: String, authNumber: String, onResult: (Boolean, String) -> Unit) {
        viewModelScope.launch {
            try {
                val response: LinkResponse = linkApi.checkAuth(email, authNumber)
                if (response.success) {
                    response.token?.let { token ->
                        TokenManager.saveToken(context, token)
                    }
                }
                onResult(response.success, response.message)
            } catch (e: Exception) {
                onResult(false, "오류가 발생했습니다: ${e.message}")
            }
        }
    }
}
