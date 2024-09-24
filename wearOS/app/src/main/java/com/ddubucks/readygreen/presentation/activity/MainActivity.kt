package com.ddubucks.readygreen.presentation.activity

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.ddubucks.readygreen.core.network.LocationService
import com.ddubucks.readygreen.presentation.screen.BookmarkScreen
import com.ddubucks.readygreen.presentation.screen.MainScreen
import com.ddubucks.readygreen.presentation.screen.MapScreen
import com.ddubucks.readygreen.presentation.screen.NavigationScreen
import com.ddubucks.readygreen.presentation.screen.SearchResultScreen
import com.ddubucks.readygreen.presentation.screen.SearchScreen
import com.ddubucks.readygreen.presentation.theme.ReadyGreenTheme
import com.ddubucks.readygreen.presentation.viewmodel.LocationViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModelFactory

class MainActivity : ComponentActivity() {

    private val locationService: LocationService by lazy { LocationService(this) }
    private val searchViewModel: SearchViewModel by viewModels { SearchViewModelFactory(locationService) }
    private val locationViewModel: LocationViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            ReadyGreenTheme {
                val navController = rememberNavController()

                NavHost(navController = navController, startDestination = "mainScreen") {
                    // MainScreen 설정
                    composable("mainScreen") { MainScreen(navController) }
                    // BookmarkScreen
                    composable("bookmarkScreen") { BookmarkScreen() }
                    // SearchScreen
                    composable("searchScreen") {
                        SearchScreen(
                            navController = navController,
                            viewModel = searchViewModel,
                        )
                    }
                    composable("searchResultScreen/{voiceResults}") { backStackEntry ->
                        val voiceResults = backStackEntry.arguments?.getString("voiceResults")?.split(",") ?: emptyList()
                        SearchResultScreen(voiceResults = voiceResults) {
                            navController.navigate("searchScreen")
                        }
                    }
                    // MapScreen
                    composable("mapScreen") {
                        MapScreen(locationViewModel = locationViewModel)
                    }
                    // NavigationScreen
                    composable("navigationScreen") { NavigationScreen() }
                }
            }
        }
    }
}
