package com.ddubucks.readygreen.presentation.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.bookmark.BookmarkApi
import com.ddubucks.readygreen.presentation.retrofit.bookmark.BookmarkResponse
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers
import retrofit2.awaitResponse

class BookmarkViewModel : ViewModel() {

    private val _bookmark = MutableStateFlow<List<BookmarkResponse>?>(null)
    val bookmark: StateFlow<List<BookmarkResponse>?> = _bookmark

    fun getBookmarks() {
        val bookmarkApi = RestClient.createService(BookmarkApi::class.java)

        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    bookmarkApi.getBookmarks().awaitResponse()
                }

                if (response.isSuccessful) {
                    _bookmark.value = response.body()?.bookmarkDTOs
                } else {
                    Log.e("BookmarkViewModel", "북마크 요청 실패: ${response.code()}")
                    _bookmark.value = emptyList()
                }
            } catch (e: Exception) {
                Log.e("BookmarkViewModel", "북마크 요청 중 오류 발생", e)
                _bookmark.value = emptyList()
            }
        }
    }
}
