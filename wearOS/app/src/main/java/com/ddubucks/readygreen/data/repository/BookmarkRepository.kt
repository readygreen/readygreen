package com.ddubucks.readygreen.data.repository

import com.ddubucks.readygreen.data.model.BookmarkModel
import com.ddubucks.readygreen.utils.RetrofitClient

class BookmarkRepository {

    suspend fun getBookmark(): List<BookmarkModel> {
        return RetrofitClient.apiService.getBookmark()
    }
}
