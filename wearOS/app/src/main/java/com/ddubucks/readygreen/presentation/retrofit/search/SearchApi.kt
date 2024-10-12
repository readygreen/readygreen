package com.ddubucks.readygreen.presentation.retrofit.search

import retrofit2.http.GET
import retrofit2.http.Query

interface SearchApi {
    @GET("maps/api/place/nearbysearch/json")
    suspend fun searchPlaces(
        @Query("location") location: String,
        @Query("radius") radius: Int = 5000, // 반경 5키로
        @Query("keyword") keyword: String,
        @Query("key") apiKey: String,
    ): SearchResponse
}