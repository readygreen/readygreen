package com.ddubucks.readygreen.presentation.activity

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.core.app.ActivityCompat
import com.ddubucks.readygreen.presentation.screen.BluetoothConnectionScreen
import java.io.InputStream
import java.io.OutputStream
import java.util.*

class BluetoothActivity : ComponentActivity() {
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private lateinit var bluetoothSocket: BluetoothSocket
    private val MY_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    private val deviceAddress = "00:11:22:33:44:55" // 연결할 모바일 기기의 MAC 주소

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            BluetoothConnectionScreen(
                connectToBluetoothDevice = { connectToBluetoothDevice() },
                receivedMessage = { getBluetoothMessage() }
            )
        }
    }

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
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                return
            }
            bluetoothSocket = device.createRfcommSocketToServiceRecord(MY_UUID)
            bluetoothSocket.connect()
        } catch (e: Exception) {
            e.printStackTrace()
            println("Failed to connect to Bluetooth device.")
        }
    }

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

    override fun onDestroy() {
        super.onDestroy()
        bluetoothSocket.close()
    }
}
