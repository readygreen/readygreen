package com.ddubucks.readygreen.presentation.retrofit.link

import okhttp3.ResponseBody
import retrofit2.http.GET
import retrofit2.http.Query

interface LinkApi {
    @GET("link/check")
    suspend fun checkAuth(
        @Query("email") email: String,
        @Query("authNumber") authNumber: String,
        @Query("deviceToken") deviceToken: String
    ): ResponseBody
}
