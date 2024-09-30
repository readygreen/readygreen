package com.ddubucks.readygreen.presentation.retrofit.bookmark

import retrofit2.Call
import retrofit2.http.GET

interface BookmarkApi {
    @GET("bookmark")
    fun getBookmarks(): Call<BookmarkListResponse>
}

data class BookmarkListResponse(
    val bookmarkDTOs: List<BookmarkResponse>
)
