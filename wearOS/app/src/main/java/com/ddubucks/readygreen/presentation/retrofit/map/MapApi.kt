package com.ddubucks.readygreen.presentation.retrofit.map

import retrofit2.http.GET
import retrofit2.http.Query

interface MapApi {
    @GET("map")
    suspend fun getMap(
        @Query("latitude") latitude: Double,
        @Query("longitude") longitude: Double,
        @Query("radius") radius: Int
    ): MapResponse
}
