package com.ddubucks.readygreen.presentation.activity

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.core.app.ActivityCompat
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.screen.*
import com.ddubucks.readygreen.presentation.theme.ReadyGreenTheme
import com.ddubucks.readygreen.presentation.viewmodel.LocationViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModelFactory

class MainActivity : ComponentActivity() {

    // 위치 서비스
    private val locationService: LocationService by lazy { LocationService(this) }
    private val searchViewModel: SearchViewModel by viewModels { SearchViewModelFactory(locationService) }
    private val locationViewModel: LocationViewModel by viewModels()

    // 위치 권한 요청을 위한 Launcher
    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        if (isGranted) {
            locationService.requestLocationUpdates()
        } else {
            // 권한이 거부되었을 때 처리
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 위치 권한 확인 및 업데이트 시작
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            // 권한이 없으면 권한 요청
            requestPermissionLauncher.launch(Manifest.permission.ACCESS_FINE_LOCATION)
        } else {
            // 권한이 있으면 위치 업데이트 시작
            locationViewModel.startLocationUpdates()
        }

        setContent {
            ReadyGreenTheme {
                val navController = rememberNavController()

                NavHost(navController = navController, startDestination = "mainScreen") {
                    composable("mainScreen") { MainScreen(navController) }
                    composable("bookmarkScreen") { BookmarkScreen() }
                    composable("searchScreen") {
                        SearchScreen(navController = navController, viewModel = searchViewModel)
                    }
                    composable("searchResultScreen/{voiceResults}") { backStackEntry ->
                        val voiceResults = backStackEntry.arguments?.getString("voiceResults")?.split(",") ?: emptyList()
                        SearchResultScreen(voiceResults = voiceResults) {
                            navController.navigate("searchScreen")
                        }
                    }
                    composable("mapScreen") {
                        MapScreen(locationViewModel = locationViewModel)
                    }
                    composable("navigationScreen") { NavigationScreen() }
                }
            }
        }
    }
}