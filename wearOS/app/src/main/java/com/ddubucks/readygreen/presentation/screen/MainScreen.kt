package com.ddubucks.readygreen.presentation.screen

import android.Manifest
import android.content.pm.PackageManager
import android.location.Location
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.wear.compose.material.ScalingLazyColumn
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.items
import androidx.navigation.NavHostController
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.data.model.ButtonIconModel
import com.ddubucks.readygreen.presentation.components.ButtonIconItem
import com.ddubucks.readygreen.presentation.theme.Black
import com.ddubucks.readygreen.presentation.theme.Yellow
import com.google.android.gms.location.LocationServices
import h1Style

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(navController: NavHostController) {

    val context = LocalContext.current
    val fusedLocationClient = remember { LocationServices.getFusedLocationProviderClient(context) }
    var latitude by remember { mutableStateOf<Double?>(null) }
    var longitude by remember { mutableStateOf<Double?>(null) }
    var permissionGranted by remember { mutableStateOf(false) }
    val locationService = remember { LocationService() }

    // 위치 권한 요청
    val locationPermission = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        permissionGranted = isGranted
        if (isGranted) {
            locationService.getLastLocation(fusedLocationClient) { lat, long ->
                latitude = lat
                longitude = long
            }
        }
    }

    // 위치 권한이 없을 때 요청
    LaunchedEffect(key1 = Unit) {
        if (ContextCompat.checkSelfPermission(
                context, Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            locationPermission.launch(Manifest.permission.ACCESS_FINE_LOCATION)
        } else {
            permissionGranted = true
            locationService.getLastLocation(fusedLocationClient) { lat, long ->
                latitude = lat
                longitude = long
            }
        }
    }

    val buttonList = listOf(
        ButtonIconModel(R.drawable.bookmark_icon, "자주가는 목적지"),
        ButtonIconModel(R.drawable.voice_search_icon, "음성검색"),
        ButtonIconModel(R.drawable.map_icon, "주변 신호등 보기"),
        // TODO 길안내 시작 코드와 연결
        ButtonIconModel(R.drawable.arrow_straight, "길안내"),
        ButtonIconModel(R.drawable.arrow_straight, "로그인")
    )
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {

        ScalingLazyColumn {
            item {
                Text(
                    text = "언제그린",
                    color = Yellow,
                    style = h1Style,
                )
            }
            item {
                Spacer(modifier = Modifier.height(10.dp))
            }
            items(buttonList) { item ->
                ButtonIconItem(item = item, onClick = {
                    when (item.label) {
                        "자주가는 목적지" -> {
                            navController.navigate("bookmarkScreen")
                        }
                        "음성검색" -> {
                            navController.navigate("searchScreen")
                        }
                        "주변 신호등 보기" -> {
                            navController.navigate("mapScreen")
                        }
                        "길안내" -> {
                            navController.navigate("navigationScreen")
                        }
                        "로그인" -> {
                            navController.navigate("initialScreen")
                        }
                    }
                })
            }
        }
    }
}

