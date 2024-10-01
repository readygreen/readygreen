package com.ddubucks.readygreen.presentation.components

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import androidx.compose.ui.graphics.toArgb
import com.ddubucks.readygreen.presentation.retrofit.map.BlinkerDTO
import com.ddubucks.readygreen.presentation.theme.Gray
import com.ddubucks.readygreen.presentation.theme.Green
import com.ddubucks.readygreen.presentation.theme.Red

fun createTrafficlightBitmap(item: BlinkerDTO): Bitmap {
    val trafficlight = Bitmap.createBitmap(50, 50, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(trafficlight)

    val pinColor = when (item.currentState) {
        "RED" -> Red.toArgb()
        "GREEN" -> Green.toArgb()
        else -> Gray.toArgb()
    }

    val paint = Paint().apply {
        color = pinColor
        isAntiAlias = true
    }
    canvas.drawCircle(25f, 25f, 25f, paint)

    val textPaint = Paint().apply {
        color = android.graphics.Color.WHITE
        textSize = 24f
        textAlign = Paint.Align.CENTER
    }

    canvas.drawText(item.remainingTime.toString(), 25f, 25f + (textPaint.textSize / 2) - 5, textPaint)

    return trafficlight
}

