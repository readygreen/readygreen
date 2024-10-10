package com.ddubucks.readygreen.presentation.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.GoogleRestClient
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.bookmark.BookmarkApi
import com.ddubucks.readygreen.presentation.retrofit.bookmark.BookmarkResponse
import com.ddubucks.readygreen.presentation.retrofit.bookmark.PlaceNameApi
import com.ddubucks.readygreen.BuildConfig
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers
import retrofit2.awaitResponse

class BookmarkViewModel : ViewModel() {

    private val _bookmark = MutableStateFlow<List<BookmarkResponse>>(emptyList())
    val bookmark: StateFlow<List<BookmarkResponse>> = _bookmark
    val apiKey = BuildConfig.MAPS_API_KEY

    fun getBookmarks() {
        val bookmarkApi = RestClient.createService(BookmarkApi::class.java)

        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    bookmarkApi.getBookmarks().awaitResponse()
                }

                if (response.isSuccessful) {
                    val bookmarkList = response.body()?.bookmarkDTOs ?: emptyList()

                    val updatedBookmarks = bookmarkList.map { bookmark ->
                        val placeName = getPlaceName(bookmark.destinationName)
                        if (placeName != null) {
                            bookmark.copy(destinationName = placeName)
                        } else {
                            bookmark
                        }
                    }

                    _bookmark.value = updatedBookmarks
                } else {
                    Log.e("BookmarkViewModel", "북마크 요청 실패: ${response.code()} - ${response.message()}")
                    _bookmark.value = emptyList()
                }
            } catch (e: Exception) {
                Log.e("BookmarkViewModel", "북마크 요청 중 오류 발생: ${e.localizedMessage}", e)
                _bookmark.value = emptyList()
            }
        }
    }


    private suspend fun getPlaceName(address: String): String? {
        val placeNameApi = GoogleRestClient.create(PlaceNameApi::class.java)

        return try {
            val response = withContext(Dispatchers.IO) {
                placeNameApi.getPlaceName(address, apiKey).awaitResponse()
            }

            if (response.isSuccessful && response.body() != null) {
                val results = response.body()?.results
                if (results != null && results.isNotEmpty()) {
                    results[0].formattedAddress
                } else {
                    null
                }
            } else {
                Log.e("BookmarkViewModel", "Geocoding 요청 실패: ${response.code()} - ${response.message()}")
                null
            }
        } catch (e: Exception) {
            Log.e("BookmarkViewModel", "Geocoding 요청 중 오류 발생: ${e.localizedMessage}", e)
            null
        }
    }
}