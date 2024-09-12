package com.ddubucks.readygreen.presentation.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.data.model.BookmarkModel
import com.ddubucks.readygreen.data.repository.BookmarkRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class BookmarkViewModel : ViewModel() {

    // BookmarkRepository를 직접 생성
    private val repository = BookmarkRepository()

    // 데이터 상태를 Flow로 관리
    private val _bookMark = MutableStateFlow<List<BookmarkModel>>(emptyList())
    val bookmark: StateFlow<List<BookmarkModel>> get() = _bookMark

    init {
        fetchBookmark()  // ViewModel 초기화 시점에 데이터 로드
    }

    private fun fetchBookmark() {
        viewModelScope.launch {
            try {
                val locations = repository.getBookmark()
                _bookMark.value = locations
            } catch (e: Exception) {
                Log.e("BookmarkViewModel", "Failed to fetch bookmarks", e)
            }
        }
    }
}
