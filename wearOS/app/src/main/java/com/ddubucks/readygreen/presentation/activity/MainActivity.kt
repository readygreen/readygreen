package com.ddubucks.readygreen.presentation.activity

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.ddubucks.readygreen.presentation.screen.FavoritesScreen
import com.ddubucks.readygreen.presentation.screen.MainScreen
import com.ddubucks.readygreen.presentation.screen.MapScreen
import com.ddubucks.readygreen.presentation.screen.SearchScreen
import com.ddubucks.readygreen.presentation.theme.ReadyGreenTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            ReadyGreenTheme {

                val navController = rememberNavController()

                // NavHost 설정
                NavHost(navController = navController, startDestination = "mainScreen") {
                    // MainScreen 설정
                    composable("mainScreen") { MainScreen(navController) }
                    // FavoriteScreen 설정
                    composable("favoriteScreen") { FavoritesScreen() }
                    composable("searchScreen") { SearchScreen() }
                    composable("mapScreen") { MapScreen() }

                }
            }
        }
    }
}
