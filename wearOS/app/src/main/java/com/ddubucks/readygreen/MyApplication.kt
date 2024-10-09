package com.ddubucks.readygreen

import android.app.Application
import com.ddubucks.readygreen.presentation.retrofit.TokenManager

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        TokenManager.initialize(this)
    }
}
