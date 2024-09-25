package com.ddubucks.readygreen.presentation.activity

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.core.app.ActivityCompat
import androidx.lifecycle.lifecycleScope
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.ddubucks.readygreen.core.service.BluetoothService
import com.ddubucks.readygreen.core.service.LocationService
import com.ddubucks.readygreen.presentation.screen.*
import com.ddubucks.readygreen.presentation.theme.ReadyGreenTheme
import com.ddubucks.readygreen.presentation.viewmodel.BluetoothViewModel
import com.ddubucks.readygreen.presentation.viewmodel.BluetoothViewModelFactory
import com.ddubucks.readygreen.presentation.viewmodel.LocationViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModelFactory
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    // Bluetooth 관련 변수
    private val bluetoothService by lazy { BluetoothService(this) }
    private val bluetoothViewModel: BluetoothViewModel by viewModels {
        BluetoothViewModelFactory(bluetoothService)
    }

    // 위치 서비스 관련 변수
    private val locationService: LocationService by lazy { LocationService(this) }
    private val searchViewModel: SearchViewModel by viewModels { SearchViewModelFactory(locationService) }
    private val locationViewModel: LocationViewModel by viewModels()

    // 위치 권한 요청을 위한 Launcher
    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        if (isGranted) {
            locationService.requestLocationUpdates() // 권한이 승인되면 위치 업데이트 요청
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

        // Bluetooth 연결 상태 구독
        lifecycleScope.launch {
            bluetoothViewModel.connected.collect { isConnected ->
                if (isConnected) {
                    // 연결이 성공적으로 되면 메시지 수신 대기
                    bluetoothViewModel.receiveMessage()
                }
            }
        }

        // Bluetooth 메시지 구독
        lifecycleScope.launch {
            bluetoothViewModel.message.collect { message ->
                // 받은 메시지 처리
                println("Received Bluetooth message: $message")
            }
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
                    composable("bluetoothScreen") {
                        val bluetoothViewModel: BluetoothViewModel by viewModels {
                            BluetoothViewModelFactory(bluetoothService)
                        }
                        BluetoothConnectionScreen(bluetoothViewModel = bluetoothViewModel)
                    }


                }
            }
        }
    }

    // 액티비티가 종료될 때 Bluetooth 연결 해제
    override fun onDestroy() {
        super.onDestroy()
        bluetoothViewModel.closeConnection()
    }
}
