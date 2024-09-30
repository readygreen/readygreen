package com.ddubucks.readygreen.presentation.retrofit.search

data class SearchResponse(
    val results: List<SearchCandidate>?
)

data class SearchCandidate(
    val name: String,
    val geometry: Geometry,
    val vicinity: String
)

data class Geometry(
    val location: Location
)

data class Location(
    val lat: Double,
    val lng: Double
)
