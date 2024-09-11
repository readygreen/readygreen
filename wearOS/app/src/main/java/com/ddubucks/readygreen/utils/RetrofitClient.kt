package com.ddubucks.readygreen.utils

import android.content.Context
import com.ddubucks.readygreen.data.api.ApiService
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitClient {

    private const val BASE_URL = "https://api.example.com/"

    // SharedPreferences에서 토큰을 불러오는 함수
    private fun getToken(context: Context): String? {
        val sharedPreferences = context.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE)
        return sharedPreferences.getString("auth_token", null)  // 저장된 토큰을 불러옴
    }

    // API 클라이언트를 반환하는 함수
    fun getApiService(context: Context): ApiService {
        // 로깅 인터셉터
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        // 인증 토큰을 추가 인터셉터
        val authInterceptor = Interceptor { chain ->
            val token = getToken(context)  // SharedPreferences에서 토큰을 가져옴
            val originalRequest: Request = chain.request()

            // 토큰이 존재하는 경우 Authorization 헤더 추가
            val modifiedRequest = if (token != null) {
                originalRequest.newBuilder()
                    .header("Authorization", "Bearer $token")
                    .build()
            } else {
                originalRequest
            }

            chain.proceed(modifiedRequest)
        }

        // OkHttpClient 설정
        val client = OkHttpClient.Builder()
            .addInterceptor(loggingInterceptor)  // 로깅 인터셉터 추가
            .addInterceptor(authInterceptor)     // 인증 토큰 인터셉터 추가
            .build()

        // Retrofit 설정
        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())  // Gson 컨버터 추가
            .client(client)  // OkHttpClient 추가
            .build()
            .create(ApiService::class.java)  // ApiService 인터페이스 생성
    }
}
