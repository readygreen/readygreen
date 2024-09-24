package com.ddubucks.readygreen.presentation.components

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import androidx.compose.ui.graphics.toArgb
import com.ddubucks.readygreen.data.model.PinModel
import com.ddubucks.readygreen.presentation.theme.Gray
import com.ddubucks.readygreen.presentation.theme.Green
import com.ddubucks.readygreen.presentation.theme.Red

fun createTrafficlightBitmap(item: PinModel): Bitmap {
    val trafficlight = Bitmap.createBitmap(50, 50, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(trafficlight)

    // 핀 색상 설정
    val pinColor = when (item.state) {
        "red" -> Red.toArgb()
        "green" -> Green.toArgb()
        else -> Gray.toArgb()
    }

    // 동그라미 그리기
    val paint = Paint().apply {
        color = pinColor // ARGB 색상 설정
        isAntiAlias = true
    }
    canvas.drawCircle(25f, 25f, 25f, paint)

    // 숫자 그리기 (한가운데에 위치)
    val textPaint = Paint().apply {
        color = android.graphics.Color.WHITE
        textSize = 24f
        textAlign = Paint.Align.CENTER
    }
    // 텍스트의 수직 위치를 조정하여 가운데에 오도록 함
    canvas.drawText(item.number.toString(), 25f, 25f + (textPaint.textSize / 2) - 5, textPaint)

    return trafficlight
}

