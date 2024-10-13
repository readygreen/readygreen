package com.ddubucks.readygreen.presentation.retrofit

import android.content.Context
import android.content.SharedPreferences
import android.util.Log

object TokenManager {
    private const val PREFS_NAME = "token_prefs"
    private const val TOKEN_KEY = "access_token"
    private const val TAG = "TokenManager"

    private lateinit var sharedPreferences: SharedPreferences

    fun initialize(context: Context) {
        sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        Log.d(TAG, "SharedPreferences initialized")
    }

    fun saveToken(token: String) {
        sharedPreferences.edit().putString(TOKEN_KEY, token).apply()
        Log.d(TAG, "access 토큰 저장: $token")
    }

    fun getToken(): String? {
        val token = sharedPreferences.getString(TOKEN_KEY, null)
        if (token != null) {
            Log.d(TAG, "access 토큰: $token")
        } else {
            Log.d(TAG, "토큰 없음")
        }
        return token
    }

    fun clearToken() {
        sharedPreferences.edit().remove(TOKEN_KEY).apply()
        Log.d(TAG, "access 토큰 삭제")

        val tokenAfterDelete = sharedPreferences.getString(TOKEN_KEY, null)
        Log.d(TAG, "access 삭제 후 토큰 값: $tokenAfterDelete")
    }
}
