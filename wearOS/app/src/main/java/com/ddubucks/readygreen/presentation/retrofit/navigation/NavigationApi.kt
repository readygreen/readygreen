package com.ddubucks.readygreen.presentation.retrofit.navigation

import retrofit2.http.GET
import retrofit2.Call

interface NavigationApi {
    @GET("map/start")
    fun getNavigation(): Call<NavigationResponse>
}
