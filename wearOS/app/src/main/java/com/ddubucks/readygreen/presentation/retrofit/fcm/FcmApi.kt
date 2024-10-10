package com.ddubucks.readygreen.presentation.retrofit.fcm

import okhttp3.RequestBody
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.PUT

interface FcmApi {
    @PUT("link/register")
    fun registerFcmToken(@Body requestBody: RequestBody): Call<Unit>
}