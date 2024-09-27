package com.ddubucks.readygreen.data.api

import com.ddubucks.readygreen.data.model.BookmarkModel
import retrofit2.http.GET

interface BookmarkApi {
    @GET("bookmark")
    suspend fun getBookmark(): List<BookmarkModel>
}
