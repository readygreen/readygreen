package com.ddubucks.readygreen.presentation.retrofit.fcm

import okhttp3.RequestBody
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST

interface FcmApi {
    @POST("fcm/register")
    fun registerFcmToken(@Body requestBody: RequestBody): Call<Unit>

    @POST("fcm/message")
    fun sendFcmMessage(@Body requestBody: RequestBody): Call<Unit>
}
