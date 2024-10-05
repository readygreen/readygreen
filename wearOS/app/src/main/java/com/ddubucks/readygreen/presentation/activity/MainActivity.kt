package com.ddubucks.readygreen.presentation.activity

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.remember
import androidx.lifecycle.Observer
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.navigation.NavController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.ddubucks.readygreen.BuildConfig
import com.ddubucks.readygreen.core.service.FirebaseMessagingService
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.screen.*
import com.ddubucks.readygreen.presentation.theme.ReadyGreenTheme
import com.ddubucks.readygreen.presentation.viewmodel.MapViewModel
import com.ddubucks.readygreen.presentation.viewmodel.NavigationViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel

class MainActivity : ComponentActivity() {
    private lateinit var navigationViewModel: NavigationViewModel
    private lateinit var broadcastReceiver: BroadcastReceiver

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // BroadcastReceiver 설정
        broadcastReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val messageType = intent?.getStringExtra("type")
                Log.d("MainActivity", "Broadcast 수신: $messageType")
                when (messageType) {
                    FirebaseMessagingService.MESSAGE_TYPE_NAVIGATION -> {
                        Log.d("MainActivity", "getNavigation() 시작")
                        navigationViewModel.getNavigation()
                        FirebaseMessagingService().resetRequestState()
                    }
                    FirebaseMessagingService.MESSAGE_TYPE_CLEAR -> {
                        Log.d("MainActivity", "clearNavigationState() 시작")
                        navigationViewModel.clearNavigationState()
                        FirebaseMessagingService().resetRequestState()
                    }
                    else -> {
                        Log.d("MainActivity", "타입: $messageType")
                    }
                }
            }
        }

        LocalBroadcastManager.getInstance(this).registerReceiver(
            broadcastReceiver,
            IntentFilter("com.ddubucks.readygreen.NAVIGATION")
        )

        setContent {
            ReadyGreenTheme {
                val navController = rememberNavController()
                val searchViewModel: SearchViewModel = viewModel()
                val locationService = remember { LocationService(this) }
                val mapViewModel: MapViewModel = viewModel()
                navigationViewModel = viewModel()

                val sharedPreferences = getSharedPreferences("token_prefs", MODE_PRIVATE)
                val token = sharedPreferences.getString("access_token", null)

                val startDestination = if (token.isNullOrEmpty()) {
                    "linkEmailScreen"
                } else {
                    "mainScreen"
                }

                NavHost(
                    navController = navController,
                    startDestination = startDestination
                ) {
                    composable("mainScreen") { MainScreen(navController, locationService) }
                    composable("bookmarkScreen") { BookmarkScreen() }
                    composable("searchScreen") {
                        SearchScreen(navController = navController, searchViewModel = searchViewModel, apiKey = BuildConfig.MAPS_API_KEY)
                    }
                    composable("searchResultScreen") {
                        SearchResultScreen(navController = navController, navigationViewModel = navigationViewModel)
                    }
                    composable("mapScreen") {
                        MapScreen(locationService = locationService, mapViewModel = mapViewModel)
                    }
                    composable("navigationScreen") {
                        NavigationScreen(navController = navController, navigationViewModel = navigationViewModel)
                    }
                    composable("linkEmailScreen") { LinkEmailScreen(navController) }
                    composable(
                        "linkScreen/{email}",
                        arguments = listOf(navArgument("email") { type = NavType.StringType })
                    ) { backStackEntry ->
                        val email = backStackEntry.arguments?.getString("email")
                        LinkScreen(navController = navController, email = email ?: "")
                    }
                }

                val navigationState = navigationViewModel.navigationState.collectAsState()
                if (!navigationState.value.isNavigating) {
                    FirebaseMessagingService().resetRequestState()
                }

            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        LocalBroadcastManager.getInstance(this).unregisterReceiver(broadcastReceiver)
    }
}
