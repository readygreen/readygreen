package com.ddubucks.readygreen.presentation.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.data.model.BookmarkModel
import com.ddubucks.readygreen.data.repository.BookmarkRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class BookmarkViewModel(private val repository: BookmarkRepository) : ViewModel() {

    private val _bookMark = MutableStateFlow<List<BookmarkModel>>(emptyList())
    val bookmark: StateFlow<List<BookmarkModel>> get() = _bookMark

    fun fetchBookmark() {
        viewModelScope.launch {
            try {
                val locations = repository.getBookmark()
                _bookMark.value = locations
            } catch (e: Exception) {
                Log.e("BookmarkView", "Failed to fetch favorite locations", e)
            }
        }
    }

}
