package com.ddubucks.readygreen.presentation.activity

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
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
import androidx.core.content.ContextCompat
import android.widget.Toast

class MainActivity : ComponentActivity() {
    private lateinit var permissionLauncher: ActivityResultLauncher<String>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 위치 권한 요청
        permissionLauncher = registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted ->
            if (isGranted) {
                initApp()
            } else {
                Toast.makeText(this, "위치 권한이 필요합니다.", Toast.LENGTH_LONG).show()
                initApp()
            }
        }

        // 토큰 상태 확인
        val sharedPreferences = getSharedPreferences("token_prefs", Context.MODE_PRIVATE)
        val token = sharedPreferences.getString("access_token", null)

        if (token.isNullOrEmpty()) {
            // 인증이 필요할 때 linkEmailScreen으로 이동
            setContent {
                ReadyGreenTheme {
                    val navController = rememberNavController()
                    NavHost(navController = navController, startDestination = "linkEmailScreen") {
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
        } else {
            // 인증이 완료된 경우 위치 권한 확인
            checkLocationPermission()
        }
    }

    private fun checkLocationPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            permissionLauncher.launch(Manifest.permission.ACCESS_FINE_LOCATION)
        } else {
            initApp()
        }
    }

    private fun initApp() {
        setContent {
            ReadyGreenTheme {
                val navController = rememberNavController()
                val locationService = remember { LocationService(this) }
                val searchViewModel: SearchViewModel = viewModel()
                val mapViewModel: MapViewModel = viewModel()
                val navigationViewModel: NavigationViewModel = viewModel()

                NavHost(navController = navController, startDestination = "mainScreen") {
                    composable("mainScreen") { MainScreen(navController, locationService) }
                    // 다른 화면들...
                    composable("bookmarkScreen") { BookmarkScreen() }
                    composable("searchScreen") {
                        SearchScreen(
                            navController = navController,
                            searchViewModel = searchViewModel,
                            apiKey = BuildConfig.MAPS_API_KEY
                        )
                    }
                    composable("searchResultScreen") {
                        SearchResultScreen(
                            navController = navController,
                            navigationViewModel = navigationViewModel
                        )
                    }
                    composable("mapScreen") {
                        MapScreen(
                            locationService = locationService,
                            mapViewModel = mapViewModel
                        )
                    }
                    composable("navigationScreen") {
                        NavigationScreen(
                            navController = navController,
                            navigationViewModel = navigationViewModel
                        )
                    }
                }
            }
        }
    }
}
