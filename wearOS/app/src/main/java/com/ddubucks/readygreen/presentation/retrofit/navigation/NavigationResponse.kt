package com.ddubucks.readygreen.presentation.retrofit.navigation

import kotlin.Double
import kotlin.String
import kotlin.Int
import kotlin.collections.List

data class NavigationResponse(
    val routeDTO: RouteDTO,
    val blinkerDTOs: List<BlinkerDTO>,
    val distance: Double,
    val time: String
)

// 경로 정보 클래스
data class RouteDTO(
    val type: String,
    val features: List<Feature>
)

// 경로의 개별 요소 (포인트 또는 선)
data class Feature(
    val type: String,
    val geometry: Geometry, // 좌표 정보
    val properties: Properties // 세부 속성 정보 (경로 설명, 방향 등)
)

// 좌표 정보 클래스 (Point 또는 LineString)
data class Geometry(
    val type: String, // Point 또는 LineString
    val coordinates: Any // 좌표 데이터
) {
    // Point
    fun getCoordinatesAsDoubleArray(): List<Double>? {
        return try {
            if (type == "Point") {
                (coordinates as? List<*>)?.filterIsInstance<Double>()
            } else null
        } catch (e: Exception) {
            null
        }
    }

    // LineString
    fun getCoordinatesAsLineString(): List<List<Double>>? {
        return if (type == "LineString") {
            (coordinates as? List<*>)
                ?.filterIsInstance<List<*>>()
                ?.map { it.filterIsInstance<Double>() }
        } else null
    }
}

// 경로의 세부 정보 (경로 설명, 방향 정보 등)
data class Properties(
    val index: Int, // 경로 인덱스
    val pointIndex: Int, // 포인트 인덱스
    val name: String, // 경로 이름 (예: 도로명, 교차로명 등)
    val guidePointName: String?, // 가이드 포인트 이름 (Optional)
    val description: String, // 경로 설명 (예: "계룡로을 따라 65m 이동")
    val direction: String?, // 방향 설명 (Optional)
    val intersectionName: String?, // 교차로 이름 (Optional)
    val nearPoiName: String?, // 주변 포인트 이름 (Optional)
    val nearPoiX: String?, // 주변 포인트 X 좌표 (Optional)
    val nearPoiY: String?, // 주변 포인트 Y 좌표 (Optional)
    val crossName: String?, // 교차로 이름 (Optional)
    val totalDistance: Int, // 총 이동 거리
    val totalTime: Int, // 총 소요 시간
    val distance: Int, // 현재 세그먼트의 거리
    val time: Int, // 현재 세그먼트의 소요 시간
    val turnType: Int, // 방향 타입
    val pointType: String // 포인트 타입 (예: SP, GP 등)
)

data class BlinkerDTO(
    val id: Int,
    val startTime: String, // 시작 시간
    val greenDuration: Int, // 초록불 지속 시간 (초)
    val redDuration: Int, // 빨간불 지속 시간 (초)
    val currentState: String, // 신호 상태
    val remainingTime: Int, // 남은 시간
    val latitude: Double,
    val longitude: Double,
    val index: Int
)


// 신호등 시간
data class Time(
    val hour: Int,
    val minute: Int,
    val second: Int,
    val nano: Int
)
