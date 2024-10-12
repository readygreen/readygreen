package com.ddubucks.readygreen.presentation.retrofit.bookmark

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query

interface BookmarkApi {
    @GET("map/bookmark")
    fun getBookmarks(): Call<BookmarkListResponse>
}


interface PlaceNameApi {
    @GET("maps/api/geocode/json")
    fun getPlaceName(
        @Query("address") address: String,
        @Query("key") apiKey: String
    ): Call<PlaceResponse>
}
