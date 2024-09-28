package com.ddubucks.readygreen.presentation.retrofit.search

data class SearchResponse(
    val candidates: List<SearchCandidate>?
)

data class SearchCandidate(
    val address: String,
    val name: String,
    val geometry: Geometry
)

data class Geometry(
    val location: Location
)

data class Location(
    val lat: Double,
    val lng: Double
)