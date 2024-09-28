package com.ddubucks.readygreen.presentation.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.bookmark.BookmarkResponse
import com.ddubucks.readygreen.data.repository.BookmarkRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class BookmarkViewModel : ViewModel() {

    private val repository = BookmarkRepository()

    private val _bookMark = MutableStateFlow<List<BookmarkResponse>>(emptyList())
    val bookmark: StateFlow<List<BookmarkResponse>> get() = _bookMark

    init {
        fetchBookmark()
    }

    private fun fetchBookmark() {
        viewModelScope.launch {
            try {
                val locations = repository.getBookmark()
                _bookMark.value = locations
                Log.d("BookmarkViewModel", "Fetched bookmarks: $locations")
            } catch (e: Exception) {
                Log.e("BookmarkViewModel", "Failed to fetch bookmarks", e)
            }
        }
    }
}
