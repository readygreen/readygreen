package com.ddubucks.readygreen.core.service

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import androidx.core.app.ActivityCompat
import android.content.pm.PackageManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.InputStream
import java.util.*

class BluetoothService(private val context: Context) {

    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private lateinit var bluetoothSocket: BluetoothSocket
    private val MY_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    // 연결하려는 기기의 MAC 주소
    private val deviceAddress = "00:11:22:33:44:55" // TODO: MAC 주소변경

    // 블루투스 연결
    suspend fun connectToDevice(): Boolean {
        return withContext(Dispatchers.IO) {
            try {
                val device: BluetoothDevice? = bluetoothAdapter?.getRemoteDevice(deviceAddress)
                if (device == null || ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    return@withContext false
                }

                bluetoothSocket = device.createRfcommSocketToServiceRecord(MY_UUID)
                bluetoothSocket.connect()
                true
            } catch (e: Exception) {
                e.printStackTrace()
                false
            }
        }
    }

    // 블루투스 메시지 수신
    suspend fun receiveMessage(): String? {
        return withContext(Dispatchers.IO) {
            try {
                val inputStream: InputStream = bluetoothSocket.inputStream
                val buffer = ByteArray(1024)
                val bytes = inputStream.read(buffer)
                String(buffer, 0, bytes)
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }
        }
    }

    // 블루투스 연결 해제
    fun closeConnection() {
        try {
            if (::bluetoothSocket.isInitialized) {
                bluetoothSocket.close()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}