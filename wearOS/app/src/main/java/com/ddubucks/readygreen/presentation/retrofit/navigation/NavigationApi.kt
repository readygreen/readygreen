package com.ddubucks.readygreen.presentation.retrofit.navigation

import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query


interface NavigationApi {
    @POST("map/start")
    fun startNavigation(@Body request: NavigationRequest): Call<NavigationResponse>

    @POST("map/guide")
    fun finishNavigation()
        // TODO 길안내 완료

    @DELETE("map/guide")
    fun stopNavigation(
        @Query("isWatch") isWatch: Boolean
    ): Call<Void>

    @GET("map/guide")
    fun getNavigation()
        // TODO 길안내 정보 불러오기
}