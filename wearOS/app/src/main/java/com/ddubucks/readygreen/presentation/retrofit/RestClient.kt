package com.ddubucks.readygreen.presentation.retrofit

import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RestClient {

    private const val BASE_URL = "http://j11b108.p.ssafy.io/api/v1/"

    // Retrofit 인스턴스 생성
    fun create(accessToken: String): Retrofit {

        // 로깅 인터셉터
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        // OkHttp 클라이언트 생성 시 토큰 인터셉터 추가
        val client = OkHttpClient.Builder()
            .addInterceptor(loggingInterceptor)
            .addInterceptor(TokenInterceptor(accessToken))  // TokenInterceptor 추가
            .build()

        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    // Retrofit 서비스 생성
    fun <T> createService(serviceClass: Class<T>, accessToken: String): T {
        return create(accessToken).create(serviceClass)
    }
}
