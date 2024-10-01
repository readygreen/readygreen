package com.ddubucks.readygreen.core.service

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import androidx.core.content.ContextCompat
import com.google.android.gms.location.*

class LocationService(private val context: Context) {

    private val fusedLocationClient: FusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(context)

    private var locationRequest: LocationRequest = LocationRequest.Builder(
        Priority.PRIORITY_BALANCED_POWER_ACCURACY,
        10000
    ).setMinUpdateIntervalMillis(5000)
        .build()

    private var locationCallback: LocationCallback? = null

    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    @SuppressLint("MissingPermission")
    fun getLastLocation(onLocationReceived: (Location?) -> Unit) {
        if (hasLocationPermission()) {
            fusedLocationClient.lastLocation
                .addOnSuccessListener { location: Location? ->
                    onLocationReceived(location)
                }
                .addOnFailureListener {
                    onLocationReceived(null)
                }
        } else {
            onLocationReceived(null)
        }
    }

    @SuppressLint("MissingPermission")
    fun startLocationUpdates(onLocationUpdated: (Location) -> Unit) {
        if (hasLocationPermission()) {
            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    locationResult.lastLocation?.let { location ->
                        onLocationUpdated(location)
                    }
                }
            }
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback!!, Looper.getMainLooper())
        }
    }

    fun stopLocationUpdates() {
        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it)
        }
    }

    fun adjustLocationRequest(priority: Int, interval: Long) {
        locationRequest = LocationRequest.Builder(
            priority,
            interval
        ).setMinUpdateIntervalMillis(5000)
            .build()
    }
}
