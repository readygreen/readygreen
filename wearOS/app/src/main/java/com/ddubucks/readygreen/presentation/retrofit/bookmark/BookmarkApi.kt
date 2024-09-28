package com.ddubucks.readygreen.presentation.retrofit.bookmark

import retrofit2.http.GET

interface BookmarkApi {
    @GET("bookmark")
    suspend fun getBookmark(): List<BookmarkResponse>
}