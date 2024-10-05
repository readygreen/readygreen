package com.ddubucks.readygreen.presentation.retrofit.bookmark

import retrofit2.Call
import retrofit2.http.GET

interface BookmarkApi {
    @GET("map/bookmark")
    fun getBookmarks(): Call<BookmarkListResponse>
}



