package com.ddubucks.readygreen.presentation.retrofit.bookmark

data class BookmarkListResponse(
    val bookmarkDTOs: List<BookmarkResponse>
)

data class BookmarkResponse(
    val id: Int,
    val name: String,
    val destinationName: String,
    val latitude: Double,
    val longitude: Double,
    val alertTime: String,
    val placeId: String
)
