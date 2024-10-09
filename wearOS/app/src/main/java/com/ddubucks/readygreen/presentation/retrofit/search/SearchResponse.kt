package com.ddubucks.readygreen.presentation.retrofit.search

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class SearchResponse(
    val results: List<SearchCandidate>?
) : Parcelable

@Parcelize
data class SearchCandidate(
    val name: String,
    val geometry: Geometry,
    val vicinity: String
) : Parcelable

@Parcelize
data class Geometry(
    val location: Location
) : Parcelable

@Parcelize
data class Location(
    val lat: Double,
    val lng: Double
) : Parcelable
