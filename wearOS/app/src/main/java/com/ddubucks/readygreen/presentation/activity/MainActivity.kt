package com.ddubucks.readygreen.presentation.activity

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.remember
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.ddubucks.readygreen.BuildConfig
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.screen.*
import com.ddubucks.readygreen.presentation.theme.ReadyGreenTheme
import com.ddubucks.readygreen.presentation.viewmodel.MapViewModel
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel
import com.google.android.gms.location.LocationServices

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            ReadyGreenTheme {
                val navController = rememberNavController()
                val searchViewModel: SearchViewModel = viewModel()
                val fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
                val locationService = remember { LocationService(this) }
                val mapViewModel: MapViewModel = viewModel()
                val navigationViewModel: NavigationViewModel = viewModel()
                val sharedPreferences = getSharedPreferences("token_prefs", Context.MODE_PRIVATE)
                val token = sharedPreferences.getString("accessToken", null)

                NavHost(
                    navController = navController,
                    startDestination = if (token.isNullOrEmpty()) "linkEmailScreen" else "mainScreen"
                ) {
                    // MainScreen
                    composable("mainScreen") { MainScreen(navController) }

                    // BookmarkScreen
                    composable("bookmarkScreen") { BookmarkScreen() }

                    // SearchScreen
                    composable("searchScreen") {
                        SearchScreen(
                            navController = navController,
                            fusedLocationClient = fusedLocationClient,
                            searchViewModel = searchViewModel,
                            apiKey = BuildConfig.MAPS_API_KEY
                        )
                    }

                    // SearchResultScreen
                    composable("searchResultScreen") {
                        SearchResultScreen(
                            navController = navController,
                            navigationViewModel = navigationViewModel
                        )
                    }

                    // MapScreen
                    composable("mapScreen") {
                        MapScreen(
                            locationService = locationService,
                            mapViewModel = mapViewModel
                        )
                    }

                    // NavigationScreen
                    composable("navigationScreen") {
                        NavigationScreen(
                            navigationViewModel = navigationViewModel
                        )
                    }

                    // Authentication
                    composable("linkEmailScreen") { LinkEmailScreen(navController) }
                    composable(
                        "linkScreen/{email}",
                        arguments = listOf(navArgument("email") { type = NavType.StringType })
                    ) { backStackEntry ->
                        val email = backStackEntry.arguments?.getString("email")
                        LinkScreen(navController = navController, email = email ?: "")
                    }
                }
            }
        }
    }
}
