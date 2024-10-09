package com.ddubucks.readygreen.presentation.retrofit

import android.content.Context
import android.content.SharedPreferences

object TokenManager {
    private const val PREFS_NAME = "token_prefs"
    private const val TOKEN_KEY = "access_token"

    private lateinit var sharedPreferences: SharedPreferences

    fun initialize(context: Context) {
        sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    // 토큰 저장
    fun saveToken(token: String) {
        sharedPreferences.edit().putString(TOKEN_KEY, token).apply()
    }

    // 저장된 토큰 가져오기
    fun getToken(): String? {
        return sharedPreferences.getString(TOKEN_KEY, null)
    }

    // 토큰 삭제
    fun clearToken() {
        sharedPreferences.edit().remove(TOKEN_KEY).apply()
    }
}
