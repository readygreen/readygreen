package com.ddubucks.readygreen.presentation.activity

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
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
import com.ddubucks.readygreen.core.network.LocationService
import com.ddubucks.readygreen.presentation.screen.*
import com.ddubucks.readygreen.presentation.theme.ReadyGreenTheme
import com.ddubucks.readygreen.presentation.viewmodel.LocationViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModel
import com.ddubucks.readygreen.presentation.viewmodel.SearchViewModelFactory
import java.io.InputStream
import java.util.UUID

class MainActivity : ComponentActivity() {

    // Bluetooth 관련 변수
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private lateinit var bluetoothSocket: BluetoothSocket
    private val MY_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    private val deviceAddress = "00:11:22:33:44:55" // TODO 연결할 모바일 기기의 MAC 주소 수정

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

    // Bluetooth 연결 시도 함수
    private fun connectToBluetoothDevice() {
        try {
            val device: BluetoothDevice? = bluetoothAdapter?.getRemoteDevice(deviceAddress)
            if (device == null) {
                println("Bluetooth device not found.")
                return
            }
            if (ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                // 권한 요청이 필요한 경우
                requestPermissionLauncher.launch(Manifest.permission.BLUETOOTH_CONNECT)
                return
            }
            bluetoothSocket = device.createRfcommSocketToServiceRecord(MY_UUID)
            bluetoothSocket.connect()
        } catch (e: Exception) {
            e.printStackTrace()
            println("Failed to connect to Bluetooth device.")
        }
    }

    // Bluetooth 메시지 수신 함수
    private fun getBluetoothMessage(): String {
        return try {
            val inputStream: InputStream = bluetoothSocket.inputStream
            val buffer = ByteArray(1024)
            val bytes = inputStream.read(buffer)
            String(buffer, 0, bytes)
        } catch (e: Exception) {
            e.printStackTrace()
            "Error receiving message"
        }
    }

    // Bluetooth 연결 해제 함수
    override fun onDestroy() {
        super.onDestroy()
        if (::bluetoothSocket.isInitialized) {
            bluetoothSocket.close()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 위치 권한이 있는지 확인
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            // 권한이 없다면 권한 요청
            requestPermissionLauncher.launch(Manifest.permission.ACCESS_FINE_LOCATION)
        } else {
            // 권한이 있으면 바로 위치 업데이트 요청
            locationService.requestLocationUpdates()
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
                        BluetoothConnectionScreen(
                            connectToBluetoothDevice = { connectToBluetoothDevice() },
                            receivedMessage = { getBluetoothMessage() }
                        )
                    }
                }
            }
        }
    }
}
