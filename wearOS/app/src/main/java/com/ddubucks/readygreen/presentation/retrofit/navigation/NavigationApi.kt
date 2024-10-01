package com.ddubucks.readygreen.presentation.retrofit.navigation

import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST


interface NavigationApi {
    @POST("map/start")
    fun startNavigation(@Body request: NavigationRequest): Call<NavigationResponse>
}
