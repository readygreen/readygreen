package com.ddubucks.readygreen.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.ddubucks.readygreen.core.network.LocationService

class SearchViewModelFactory(private val locationService: LocationService) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(SearchViewModel::class.java)) {
            return SearchViewModel(locationService) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
