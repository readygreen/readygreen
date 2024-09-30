package com.ddubucks.readygreen.presentation.activity

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
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
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel
import com.google.android.gms.location.LocationServices

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            ReadyGreenTheme {
                val navController = rememberNavController()
                val searchViewModel: SearchViewModel = viewModel()

                // Context를 사용해 FusedLocationProviderClient 및 LocationService 인스턴스 생성
                val fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
                val locationService = LocationService()

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
                            viewModel = searchViewModel,
                            apiKey = BuildConfig.MAPS_API_KEY
                        )
                    }

                    // 검색 결과를 넘겨주는 SearchResultScreen
                    composable("searchResultScreen") {
                        SearchResultScreen(navController = navController)
                    }

                    // MapScreen
                    composable("mapScreen") {
                        MapScreen(
                            locationService = locationService,  // Context 전달된 LocationService 사용
                            fusedLocationClient = fusedLocationClient
                        )
                    }

                    // NavigationScreen
                    composable(
                        "navigationScreen/{name}/{lat}/{lng}",
                        arguments = listOf(
                            navArgument("name") { type = NavType.StringType },
                            navArgument("lat") { type = NavType.FloatType },
                            navArgument("lng") { type = NavType.FloatType }
                        )
                    ) { backStackEntry ->
                        val name = backStackEntry.arguments?.getString("name")
                        val lat = backStackEntry.arguments?.getFloat("lat")
                        val lng = backStackEntry.arguments?.getFloat("lng")
                        NavigationScreen(name = name, lat = lat, lng = lng)
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
