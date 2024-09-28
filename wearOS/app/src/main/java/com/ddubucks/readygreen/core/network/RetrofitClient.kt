package com.ddubucks.readygreen.core.network

import com.ddubucks.readygreen.presentation.retrofit.bookmark.BookmarkApi
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitClient {

    private const val BASE_URL = "http://j11b108.p.ssafy.io/api/v1/"

    // 클라이언트 생성 시 토큰 인터셉터 추가
//    private val client = OkHttpClient.Builder()
//        .addInterceptor(TokenInterceptor { getTokenFromStorage() })
//        .build()

    val apiService: BookmarkApi by lazy {
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        val client = OkHttpClient.Builder()
            .addInterceptor(loggingInterceptor)
            .build()

        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .client(client)
            .build()
            .create(BookmarkApi::class.java)
    }
}
